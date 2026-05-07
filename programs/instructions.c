#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "instructions.h"
#include "vga.h"
#include "lcd_display.h"
#include "uart.h"
#include "framebuffer.h"
#include "sd_spi.h"
#include "ff.h"

#define BUFFER_MAX_LENGTH 32

// ---------------------------------------------------------------------------
// FatFs state
// ---------------------------------------------------------------------------
static FATFS  g_fs;          // mounted filesystem
static FIL    g_file;        // one open file at a time

// Big BMP scratch buffer. Lives in .bss → SDRAM. Sized for 320×240×24bpp + header.
__attribute__((aligned(4)))
static uint8_t g_bmp_buf[256 * 1024];

// ---------------------------------------------------------------------------
// Help
// ---------------------------------------------------------------------------
void Help(void) {
    char *banner = "\r\n----------------------------------------------------------------";
    printf(banner);
    printf("\r\n    Debugger Command Summary");
    printf(banner);
    printf("\r\n    c   Clear framebuffer to a colour");
    printf("\r\n    m   Mount SD card");
    printf("\r\n    l   List files in root directory");
    printf("\r\n    b   Load and display a .bmp file");
    printf("\r\n    i   Show SD card info");
    printf("\r\n    d   Dump sector 0");
    printf("\r\n    h   Help menu");
    printf(banner);
}

// ---------------------------------------------------------------------------
// SD / FatFs commands
// ---------------------------------------------------------------------------

static void cmd_dump_sector0(void) {
    uint8_t buf[512];
    int rc = sd_read_block(0, buf);
    if (rc != SD_OK) {
        printf("\r\nsd_read_block failed: %d", rc);
        return;
    }
    printf("\r\n--- Sector 0 ---");
    printf("\r\nFirst 16 bytes: ");
    for (int i = 0; i < 16; i++) printf("%02X ", buf[i]);
    printf("\r\nBytes 510-511:  %02X %02X (expect 55 AA)", buf[510], buf[511]);
    printf("\r\nPartition 1 entry (offset 0x1BE):");
    printf("\r\n  Status:    %02X", buf[0x1BE]);
    printf("\r\n  Type:      %02X (expect 0B or 0C for FAT32)", buf[0x1BE + 4]);
    uint32_t start_lba = (uint32_t)buf[0x1BE + 8]
                       | ((uint32_t)buf[0x1BE + 9]  << 8)
                       | ((uint32_t)buf[0x1BE + 10] << 16)
                       | ((uint32_t)buf[0x1BE + 11] << 24);
    uint32_t num_sectors = (uint32_t)buf[0x1BE + 12]
                         | ((uint32_t)buf[0x1BE + 13] << 8)
                         | ((uint32_t)buf[0x1BE + 14] << 16)
                         | ((uint32_t)buf[0x1BE + 15] << 24);
    printf("\r\n  Start LBA: %lu", (unsigned long)start_lba);
    printf("\r\n  Sectors:   %lu", (unsigned long)num_sectors);
}

static void cmd_mount(void) {
    printf("\r\nMounting SD card...");
    FRESULT res = f_mount(&g_fs, "", 1);
    if (res != FR_OK) {
        printf("\r\nf_mount failed: %d", res);
        return;
    }
    printf("\r\nMounted OK.");
}

static void cmd_card_info(void) {
    int t = sd_get_card_type();
    const char *type_str = (t == SD_TYPE_SDHC) ? "SDHC/SDXC"
                         : (t == SD_TYPE_SDSC) ? "SDSC"
                         : "none";
    uint32_t sectors = sd_get_sector_count();
    printf("\r\nCard type: %s", type_str);
    printf("\r\nSectors:   %lu", (unsigned long)sectors);
    printf("\r\nCapacity:  %lu MB", (unsigned long)(sectors / 2048));
}

static void cmd_list_dir(void) {
    DIR dir;
    FILINFO fno;
    FRESULT res = f_opendir(&dir, "/");
    if (res != FR_OK) {
        printf("\r\nf_opendir failed: %d (run 'm' first?)", res);
        return;
    }
    printf("\r\nFiles in /:");
    for (;;) {
        res = f_readdir(&dir, &fno);
        if (res != FR_OK || fno.fname[0] == 0) break;
        printf("\r\n  %s%s  (%lu bytes)",
               (fno.fattrib & AM_DIR) ? "[DIR] " : "      ",
               fno.fname,
               (unsigned long)fno.fsize);
    }
    f_closedir(&dir);
}

static void prompt_filename(char *buf, int max_len) {
    printf("\r\nFilename: ");
    FlushKeyboard();
    int i = 0;
    /*while (i < max_len - 1) {
        char c;
        scanf("%c", &c);
        if (c == '\r' || c == '\n') break;
        buf[i++] = c;
    }
    buf[i] = '\0';*/
    scanf("%s", buf);
}

static void cmd_load_bmp(void) {
    char path[64];
    prompt_filename(path, sizeof(path));
    if (path[0] == '\0') {
        printf("\r\nNo filename.");
        return;
    }

    printf("\r\nOpening '%s'...", path);
    FRESULT res = f_open(&g_file, path, FA_READ);
    if (res != FR_OK) {
        printf("\r\nf_open failed: %d", res);
        return;
    }

    FSIZE_t fsize = f_size(&g_file);
    printf("\r\nSize: %lu bytes", (unsigned long)fsize);
    if (fsize > sizeof(g_bmp_buf)) {
        printf("\r\nToo big for buffer (%u). Aborting.",
               (unsigned)sizeof(g_bmp_buf));
        f_close(&g_file);
        return;
    }

    UINT br, total = 0;
    while (total < fsize) {
        UINT want = (fsize - total > 4096) ? 4096 : (UINT)(fsize - total);
        res = f_read(&g_file, g_bmp_buf + total, want, &br);
        if (res != FR_OK) {
            printf("\r\nf_read failed: %d at %lu", res, (unsigned long)total);
            f_close(&g_file);
            return;
        }
        if (br == 0) break;
        total += br;
    }
    f_close(&g_file);
    printf("\r\nLoaded %u bytes. Blitting...", (unsigned)total);

    int rc = fb_blit_bmp24(g_bmp_buf, total, 0, 0);
    if (rc != 0) {
        printf("\r\nfb_blit_bmp24 failed: %d", rc);
        printf("\r\n  -1=bad magic, -2=not 24bpp, -3=compressed");
    } else {
        printf("\r\nDone.");
    }
}

// ---------------------------------------------------------------------------
// Existing colour-fill command, unchanged
// ---------------------------------------------------------------------------
static void cmd_clear_colour(void) {
    char c1;
    printf("\r\nCOLOUR!\n(b)lue or (r)ed or (g)reen?\r\n= ");
    scanf("%c", &c1);
    switch (c1) {
        case 'b': fb_clear(FB_BLUE);  break;
        case 'r': fb_clear(FB_RED);   break;
        case 'g': fb_clear(FB_GREEN); break;
        default:  printf("\r\nInvalid choice."); break;
    }
}

// ---------------------------------------------------------------------------
// Menu
// ---------------------------------------------------------------------------
void menu(void) {
    char c0;
    while (1) {
        FlushKeyboard();
        printf("\r\n$ ");
        scanf("%c", &c0);
        switch (c0) {
            case 'c': cmd_clear_colour(); break;
            case 'm': cmd_mount();        break;
            case 'i': cmd_card_info();    break;
            case 'l': cmd_list_dir();     break;
            case 'b': cmd_load_bmp();     break;
            case 'h': Help();             break;
            case 'd': cmd_dump_sector0(); break;
            default:
                printf("\r\nUnknown command...");
                Help();
                break;
        }
    }
}

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------
int main(void) {
    char *message1 = "Rip and tear,";
    char *message2 = "until it is done.";

    Initialize_LCD();
    Init_RS232();
    LCD_line0(message1);
    LCD_line1(message2);

    Timer0_Control_Register = 0x0;
    Timer0_Data_Register    = 50000000;
    Timer0_Control_Register = 0x00000003;

    printf("\r\nWelcome to DOOM (%i)!\r\n", 1993);

    // Initialize SD card. This configures SPI itself — do NOT call SPI_Init().
    printf("\r\nInitializing SD card...");
    int sd_rc = sd_init();
    if (sd_rc != SD_OK) {
        printf("\r\nsd_init failed: %d", sd_rc);
        printf("\r\nCheck wiring, power, card insertion.");
        printf("\r\nContinuing with menu (use 'm' to retry).");
    } else {
        printf("\r\nSD OK. Auto-mounting...");
        FRESULT fr = f_mount(&g_fs, "", 1);
        if (fr != FR_OK) {
            printf("\r\nf_mount failed: %d", fr);
        } else {
            printf("\r\nMounted.");
        }
    }

    menu();
    return 0;
}

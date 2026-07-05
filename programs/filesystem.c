#include <stdio.h>
#include "filesystem.h"
#include "ff.h"
#include "sd_spi.h"
#include "uart.h"
#include "framebuffer.h"

// ---------------------------------------------------------------------------
// FatFs state
// ---------------------------------------------------------------------------
static FATFS  g_fs;
static FIL    g_file;

__attribute__((aligned(4)))
static uint8_t g_bmp_buf[512 * 1024];

// ---------------------------------------------------------------------------
// SD / FatFs commands  (non-static — called from main.c)
// ---------------------------------------------------------------------------
void init_filesystem(void) {
    FRESULT fr = f_mount(&g_fs, "", 1);
    if (fr != FR_OK)
        printf("\r\nf_mount failed: %d", fr);
    else
        printf("\r\nMounted OK.");
}

void cmd_dump_sector0(void) {
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
    uint32_t start_lba  = (uint32_t)buf[0x1BE + 8]
                        | ((uint32_t)buf[0x1BE +  9] <<  8)
                        | ((uint32_t)buf[0x1BE + 10] << 16)
                        | ((uint32_t)buf[0x1BE + 11] << 24);
    uint32_t num_sectors = (uint32_t)buf[0x1BE + 12]
                         | ((uint32_t)buf[0x1BE + 13] <<  8)
                         | ((uint32_t)buf[0x1BE + 14] << 16)
                         | ((uint32_t)buf[0x1BE + 15] << 24);
    printf("\r\n  Start LBA: %lu", (unsigned long)start_lba);
    printf("\r\n  Sectors:   %lu", (unsigned long)num_sectors);
}

void cmd_mount(void) {
    printf("\r\nMounting SD card...");
    FRESULT res = f_mount(&g_fs, "", 1);
    if (res != FR_OK) {
        printf("\r\nf_mount failed: %d", res);
        return;
    }
    printf("\r\nMounted OK.");
}

void cmd_card_info(void) {
    int t = sd_get_card_type();
    const char *type_str = (t == SD_TYPE_SDHC) ? "SDHC/SDXC"
                         : (t == SD_TYPE_SDSC) ? "SDSC"
                         : "none";
    uint32_t sectors = sd_get_sector_count();
    printf("\r\nCard type: %s", type_str);
    printf("\r\nSectors:   %lu", (unsigned long)sectors);
    printf("\r\nCapacity:  %lu MB", (unsigned long)(sectors / 2048));
}

void cmd_list_dir(void) {
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
    (void)max_len;   /* suppress unused-parameter warning */
    printf("\r\nFilename: ");
    FlushKeyboard();
    scanf("%s", buf);
}

int load_bmp_from_path(const char *path) {
    printf("\r\nOpening '%s'...", path);
    FRESULT res = f_open(&g_file, path, FA_READ);
    if (res != FR_OK) {
        printf("\r\nf_open failed: %d", res);
        return -1;
    }
    FSIZE_t fsize = f_size(&g_file);
    printf("\r\nSize: %lu bytes", (unsigned long)fsize);
    if (fsize > sizeof(g_bmp_buf)) {
        printf("\r\nToo big for buffer (%u). Aborting.",
               (unsigned)sizeof(g_bmp_buf));
        f_close(&g_file);
        return -1;
    }
    UINT br, total = 0;
    while (total < fsize) {
        UINT want = (fsize - total > 4096) ? 4096 : (UINT)(fsize - total);
        res = f_read(&g_file, g_bmp_buf + total, want, &br);
        if (res != FR_OK) {
            printf("\r\nf_read failed: %d at %lu", res, (unsigned long)total);
            f_close(&g_file);
            return -1;
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
        return -1;
    }

    printf("\r\nDone.");
    return 0;
}

void cmd_load_bmp(void) {
    char path[64];
    prompt_filename(path, sizeof(path));
    if (path[0] == '\0') {
        printf("\r\nNo filename.");
        return;
    }
    (void)load_bmp_from_path(path);
}

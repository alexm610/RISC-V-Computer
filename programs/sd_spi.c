// =============================================================================
// sd_spi.c
// SD card driver over SPI for the RISC-V soft-core.
//
// Direct port of kiwih's user_diskio_spi.c (which is itself a port of ChaN's
// reference driver from http://elm-chan.org/fsw/ff/ffsample.zip), with the
// STM32 HAL calls replaced by direct register access to the simple_spi core.
//
// Portions copyright (C) 2014, ChaN, all rights reserved.
// Portions copyright (C) 2017, kiwih, all rights reserved.
// =============================================================================
#include "sd_spi.h"
#include "spi.h"
#include "instructions.h"
#include <stddef.h>

// ---------------------------------------------------------------------------
// MMC/SD command codes (verbatim from reference)
// ---------------------------------------------------------------------------
#define CMD0    (0)         // GO_IDLE_STATE
#define CMD1    (1)         // SEND_OP_COND (MMC)
#define ACMD41  (0x80+41)   // SEND_OP_COND (SDC)
#define CMD8    (8)         // SEND_IF_COND
#define CMD9    (9)         // SEND_CSD
#define CMD10   (10)        // SEND_CID
#define CMD12   (12)        // STOP_TRANSMISSION
#define CMD16   (16)        // SET_BLOCKLEN
#define CMD17   (17)        // READ_SINGLE_BLOCK
#define CMD18   (18)        // READ_MULTIPLE_BLOCK
#define CMD23   (23)        // SET_BLOCK_COUNT (MMC)
#define ACMD23  (0x80+23)   // SET_WR_BLK_ERASE_COUNT (SDC)
#define CMD24   (24)        // WRITE_BLOCK
#define CMD25   (25)        // WRITE_MULTIPLE_BLOCK
#define CMD55   (55)        // APP_CMD
#define CMD58   (58)        // READ_OCR

// Card type flags
#define CT_MMC      0x01
#define CT_SD1      0x02
#define CT_SD2      0x04
#define CT_SDC      (CT_SD1 | CT_SD2)
#define CT_BLOCK    0x08

// ---------------------------------------------------------------------------
// Module state
// ---------------------------------------------------------------------------
static uint8_t  CardType    = 0;
static int      g_init_ok   = 0;
static uint32_t g_sector_count = 0;

// ---------------------------------------------------------------------------
// Platform-specific hardware abstraction
// These four macros/functions are the only things that depend on the platform.
// Replace them if you port to a different SPI core.
// ---------------------------------------------------------------------------

// 50 MHz / 128 = ~391 kHz -- well under SD's 400 kHz init limit.
// SPCR = 0x50: SPE=1, MSTR=1, CPOL=0, CPHA=0, SPR=00
// SPER = 0x01: SPRE=01 -> divisor 128
#define FCLK_SLOW()  do { SPI_Control = 0x50; SPI_Ext = 0x01; } while(0)

// 50 MHz / 4 = 12.5 MHz
// SPCR = 0x51: SPR=01 -> divisor 4 (with SPRE=00)
#define FCLK_FAST()  do { SPI_Control = 0x51; SPI_Ext = 0x00; } while(0)

#define CS_LOW()     do { SPI_CS = 0xFE; } while(0)
#define CS_HIGH()    do { SPI_CS = 0xFF; } while(0)

// Single byte SPI exchange. Send `dat`, return received byte.
// Does NOT touch CS.
static uint8_t xchg_spi(uint8_t dat) {
    SPI_Status = (1 << SR_SPIF) | (1 << SR_WCOL);   // clear flags
    SPI_Data   = dat;
    while (!(SPI_Status & (1 << SR_SPIF)));
    return (uint8_t)SPI_Data;
}

// Receive multiple bytes
static void rcvr_spi_multi(uint8_t *buff, unsigned int btr) {
    for (unsigned int i = 0; i < btr; i++) {
        buff[i] = xchg_spi(0xFF);
    }
}

// Send multiple bytes
static void xmit_spi_multi(const uint8_t *buff, unsigned int btx) {
    for (unsigned int i = 0; i < btx; i++) {
        xchg_spi(buff[i]);
    }
}

// ---------------------------------------------------------------------------
// Iteration-count "timer" replacing kiwih's HAL_GetTick-based timer.
// On a 50 MHz CPU each xchg_spi call takes a few microseconds at slow clock,
// faster at fast clock. We don't need precise timing -- generous overestimate
// is fine.
// ---------------------------------------------------------------------------
static int s_timer_remaining;
static void timer_on(int iters)  { s_timer_remaining = iters; }
static int  timer_running(void)  { return s_timer_remaining-- > 0; }

// ---------------------------------------------------------------------------
// Wait for card ready (returns 1 if ready, 0 on timeout)
// ---------------------------------------------------------------------------
static int wait_ready(int wait_iters) {
    uint8_t d;
    int n = wait_iters;
    do {
        d = xchg_spi(0xFF);
    } while (d != 0xFF && --n > 0);
    return (d == 0xFF) ? 1 : 0;
}

// ---------------------------------------------------------------------------
// Deselect card and release SPI (provide a dummy clock for hi-z)
// ---------------------------------------------------------------------------
static void deselect(void) {
    CS_HIGH();
    xchg_spi(0xFF);
}

// ---------------------------------------------------------------------------
// Select card and wait for ready (returns 1 OK, 0 timeout)
// ---------------------------------------------------------------------------
static int select_card(void) {
    CS_LOW();
    xchg_spi(0xFF);                  // dummy clock, force DO enabled
    if (wait_ready(250000)) return 1;
    deselect();
    return 0;
}

// ---------------------------------------------------------------------------
// Receive a data block from the MMC (returns 1 OK, 0 fail)
// ---------------------------------------------------------------------------
static int rcvr_datablock(uint8_t *buff, unsigned int btr) {
    uint8_t token;
    timer_on(100000);                 // ~200 ms at slow clock
    do {
        token = xchg_spi(0xFF);
    } while (token == 0xFF && timer_running());
    if (token != 0xFE) return 0;     // invalid start token or timeout
    rcvr_spi_multi(buff, btr);
    xchg_spi(0xFF); xchg_spi(0xFF);  // discard CRC
    return 1;
}

// ---------------------------------------------------------------------------
// Send a data block to the MMC (returns 1 OK, 0 fail)
// ---------------------------------------------------------------------------
static int xmit_datablock(const uint8_t *buff, uint8_t token) {
    uint8_t resp;
    if (!wait_ready(50000)) return 0;
    xchg_spi(token);
    if (token != 0xFD) {              // 0xFD = StopTran
        xmit_spi_multi(buff, 512);
        xchg_spi(0xFF); xchg_spi(0xFF);   // dummy CRC
        resp = xchg_spi(0xFF);
        if ((resp & 0x1F) != 0x05) return 0;
    }
    return 1;
}

// ---------------------------------------------------------------------------
// Send a command packet to the MMC. Returns R1 response.
// Reference behavior: deselect/reselect before every command except CMD12.
// ---------------------------------------------------------------------------
static uint8_t send_cmd(uint8_t cmd, uint32_t arg) {
    uint8_t n, res;

    if (cmd & 0x80) {                // ACMD<n>: prefix with CMD55
        cmd &= 0x7F;
        res = send_cmd(CMD55, 0);
        if (res > 1) return res;
    }

    if (cmd != CMD12) {
        deselect();
        if (!select_card()) return 0xFF;
    }

    xchg_spi(0x40 | cmd);
    xchg_spi((uint8_t)(arg >> 24));
    xchg_spi((uint8_t)(arg >> 16));
    xchg_spi((uint8_t)(arg >> 8));
    xchg_spi((uint8_t)(arg));

    n = 0x01;                        // dummy CRC + stop
    if (cmd == CMD0) n = 0x95;       // valid CRC for CMD0(0)
    if (cmd == CMD8) n = 0x87;       // valid CRC for CMD8(0x1AA)
    xchg_spi(n);

    if (cmd == CMD12) xchg_spi(0xFF);   // discard one byte after CMD12

    n = 10;                          // wait up to 10 bytes for response
    do {
        res = xchg_spi(0xFF);
    } while ((res & 0x80) && --n);

    return res;
}

// ---------------------------------------------------------------------------
// Public init function
// ---------------------------------------------------------------------------
int sd_init(void) {
    uint8_t  n, cmd, ty, ocr[4];

    g_init_ok      = 0;
    CardType       = 0;
    g_sector_count = 0;

    FCLK_SLOW();
    CS_HIGH();
    for (n = 10; n; n--) xchg_spi(0xFF);     // 80 dummy clocks with CS high

    ty = 0;
    if (send_cmd(CMD0, 0) == 1) {            // entered idle state
        timer_on(100000);                    // ~1 sec init timeout
        if (send_cmd(CMD8, 0x1AA) == 1) {    // SDv2?
            for (n = 0; n < 4; n++) ocr[n] = xchg_spi(0xFF);
            if (ocr[2] == 0x01 && ocr[3] == 0xAA) {
                while (timer_running() && send_cmd(ACMD41, 1UL << 30)) ;
                if (timer_running() && send_cmd(CMD58, 0) == 0) {
                    for (n = 0; n < 4; n++) ocr[n] = xchg_spi(0xFF);
                    ty = (ocr[0] & 0x40) ? (CT_SD2 | CT_BLOCK) : CT_SD2;
                }
            }
        } else {                             // not SDv2
            if (send_cmd(ACMD41, 0) <= 1) {
                ty = CT_SD1; cmd = ACMD41;
            } else {
                ty = CT_MMC; cmd = CMD1;
            }
            while (timer_running() && send_cmd(cmd, 0)) ;
            if (!timer_running() || send_cmd(CMD16, 512) != 0) {
                ty = 0;
            }
        }
    }
    CardType = ty;
    deselect();

    if (ty == 0) {
        return SD_ERR_INIT;
    }

    FCLK_FAST();
    g_init_ok = 1;

    // Read CSD to get sector count.
    {
        uint8_t csd[16];
        if (send_cmd(CMD9, 0) == 0 && rcvr_datablock(csd, 16)) {
            uint32_t csize;
            if ((csd[0] >> 6) == 1) {        // SDC v2.00
                csize = (uint32_t)csd[9]
                      + ((uint32_t)csd[8] << 8)
                      + (((uint32_t)(csd[7] & 0x3F)) << 16)
                      + 1;
                g_sector_count = csize << 10;
            } else {                         // SDC v1.XX or MMC
                uint32_t mult;
                n = (csd[5] & 0x0F)
                  + ((csd[10] & 0x80) >> 7)
                  + ((csd[9] & 0x03) << 1)
                  + 2;
                csize = (csd[8] >> 6)
                      + ((uint32_t)csd[7] << 2)
                      + (((uint32_t)(csd[6] & 0x03)) << 10)
                      + 1;
                mult = csize << (n - 9);
                g_sector_count = mult;
            }
        }
        deselect();
    }

    return SD_OK;
}

// ---------------------------------------------------------------------------
// Read one 512-byte sector
// ---------------------------------------------------------------------------
int sd_read_block(uint32_t lba, uint8_t *buf) {
    if (!g_init_ok) return SD_ERR_NOT_READY;

    if (!(CardType & CT_BLOCK)) lba *= 512;   // byte addressing for SDSC

    int ok = 0;
    if (send_cmd(CMD17, lba) == 0) {
        if (rcvr_datablock(buf, 512)) ok = 1;
    }
    deselect();
    return ok ? SD_OK : SD_ERR_READ;
}

// ---------------------------------------------------------------------------
// Write one 512-byte sector
// ---------------------------------------------------------------------------
int sd_write_block(uint32_t lba, const uint8_t *buf) {
    if (!g_init_ok) return SD_ERR_NOT_READY;

    if (!(CardType & CT_BLOCK)) lba *= 512;

    int ok = 0;
    if (send_cmd(CMD24, lba) == 0) {
        if (xmit_datablock(buf, 0xFE)) ok = 1;
    }
    deselect();
    return ok ? SD_OK : SD_ERR_WRITE;
}

// ---------------------------------------------------------------------------
// Public accessors
// ---------------------------------------------------------------------------
uint32_t sd_get_sector_count(void) {
    return g_sector_count;
}

int sd_get_card_type(void) {
    if (!g_init_ok)              return SD_TYPE_NONE;
    if (CardType & CT_BLOCK)     return SD_TYPE_SDHC;
    return SD_TYPE_SDSC;
}

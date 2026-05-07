// =============================================================================
// diskio.c
// FatFs glue layer for the SD-over-SPI driver.
// Single physical drive (drive 0) backed by sd_spi.c.
// =============================================================================
#include "ff.h"
#include "diskio.h"
#include "sd_spi.h"

// Drive 0 is the only drive in this system.
#define DRIVE_SD    0

static volatile DSTATUS g_status = STA_NOINIT;

DSTATUS disk_status(BYTE pdrv) {
    if (pdrv != DRIVE_SD) return STA_NOINIT;
    return g_status;
}

DSTATUS disk_initialize(BYTE pdrv) {
    if (pdrv != DRIVE_SD) return STA_NOINIT;

    if (sd_init() == SD_OK) {
        g_status &= (DSTATUS)~STA_NOINIT;
    } else {
        g_status = STA_NOINIT;
    }
    return g_status;
}

DRESULT disk_read(BYTE pdrv, BYTE *buf, LBA_t sector, UINT count) {
    if (pdrv != DRIVE_SD)              return RES_PARERR;
    if (g_status & STA_NOINIT)         return RES_NOTRDY;
    if (count == 0)                    return RES_PARERR;

    for (UINT i = 0; i < count; i++) {
        if (sd_read_block((uint32_t)(sector + i),
                          buf + i * 512) != SD_OK) {
            return RES_ERROR;
        }
    }
    return RES_OK;
}

#if FF_FS_READONLY == 0
DRESULT disk_write(BYTE pdrv, const BYTE *buf, LBA_t sector, UINT count) {
    if (pdrv != DRIVE_SD)              return RES_PARERR;
    if (g_status & STA_NOINIT)         return RES_NOTRDY;
    if (g_status & STA_PROTECT)        return RES_WRPRT;
    if (count == 0)                    return RES_PARERR;

    for (UINT i = 0; i < count; i++) {
        if (sd_write_block((uint32_t)(sector + i),
                           buf + i * 512) != SD_OK) {
            return RES_ERROR;
        }
    }
    return RES_OK;
}
#endif

DRESULT disk_ioctl(BYTE pdrv, BYTE cmd, void *buf) {
    if (pdrv != DRIVE_SD)         return RES_PARERR;
    if (g_status & STA_NOINIT)    return RES_NOTRDY;

    switch (cmd) {
        case CTRL_SYNC:
            // SPI mode performs each write synchronously already.
            return RES_OK;

        case GET_SECTOR_COUNT:
            *(LBA_t *)buf = (LBA_t)sd_get_sector_count();
            return RES_OK;

        case GET_SECTOR_SIZE:
            *(WORD *)buf = 512;
            return RES_OK;

        case GET_BLOCK_SIZE:
            // Erase-block size in sectors. 1 = unknown / safe default.
            *(DWORD *)buf = 1;
            return RES_OK;

        default:
            return RES_PARERR;
    }
}

#if !FF_FS_NORTC && !FF_FS_READONLY
// FatFs calls this to timestamp files. Without an RTC we return a fixed date.
DWORD get_fattime(void) {
    // Format: bits [31:25]=year-1980, [24:21]=month, [20:16]=day,
    //         [15:11]=hour, [10:5]=minute, [4:0]=second/2.
    // Fixed: 2026-01-01 00:00:00
    return ((DWORD)(2026 - 1980) << 25)
         | ((DWORD)1  << 21)
         | ((DWORD)1  << 16)
         | ((DWORD)0  << 11)
         | ((DWORD)0  <<  5)
         | ((DWORD)0);
}
#endif

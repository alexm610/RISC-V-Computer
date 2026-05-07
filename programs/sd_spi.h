// =============================================================================
// sd_spi.h
// Bare-metal SD card driver over SPI for the RISC-V soft-core.
// Supports SDSC (v1), SDHC, and SDXC cards.
// =============================================================================
#ifndef SD_SPI_H
#define SD_SPI_H

#include <stdint.h>

// Return codes
#define SD_OK              0
#define SD_ERR_INIT       -1
#define SD_ERR_TIMEOUT    -2
#define SD_ERR_BAD_RESP   -3
#define SD_ERR_READ       -4
#define SD_ERR_WRITE      -5
#define SD_ERR_NOT_READY  -6

// Card type flags (set by sd_init)
#define SD_TYPE_NONE       0
#define SD_TYPE_SDSC       1   // standard capacity, byte-addressed
#define SD_TYPE_SDHC       2   // high/extended capacity, block-addressed

// Initialize the SD card. Must be called before any read/write.
// Returns SD_OK on success, negative error code on failure.
int sd_init(void);

// Read one 512-byte block from the card.
// `lba` is the logical block address (sector number).
// `buf` must point to at least 512 bytes.
int sd_read_block(uint32_t lba, uint8_t *buf);

// Write one 512-byte block to the card.
int sd_write_block(uint32_t lba, const uint8_t *buf);

// Returns the total number of 512-byte sectors on the card,
// or 0 if the card is not initialized.
uint32_t sd_get_sector_count(void);

// Returns the detected card type (SD_TYPE_*).
int sd_get_card_type(void);

#endif // SD_SPI_H

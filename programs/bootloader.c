#include <stdint.h>
#include <stddef.h>

#include "ff.h"
#include "instructions.h"
#include "uart.h"

#define BOOT_FILENAME       "PROGRAM.BIN"
#define PROGRAM_LOAD_ADDR   0x08000000u
#define PROGRAM_LOAD_LIMIT  0x0B700000u
#define COPY_CHUNK_BYTES    4096u

static FATFS filesystem;
static FIL program_file;

static void halt(void)
{
    for (;;) {
        __asm__ volatile ("nop");
    }
}

__attribute__((noreturn))
static void start_program(uint32_t entry_address)
{
    // Leave no bootloader interrupt source active.  The RAM program owns all
    // machine state after this point and may install its own vector table.
    Timer0_Control_Register = 0;

    __asm__ volatile (
        "csrw mie, zero\n"
        "csrci mstatus, 8\n"
        "jr %0\n"
        :
        : "r" (entry_address)
        : "memory"
    );

    __builtin_unreachable();
}

int main(void)
{
    FRESULT result;
    FSIZE_t file_size;
    uint32_t loaded = 0;

    Init_RS232();
    printf("\nRISC-V SD bootloader\n");
    printf("Loading %s at 0x%x\n", BOOT_FILENAME, PROGRAM_LOAD_ADDR);

    // Immediate mounting asks FatFs to initialize drive 0, which calls the
    // existing SD-over-SPI disk_initialize() implementation.
    result = f_mount(&filesystem, "", 1);
    if (result != FR_OK) {
        printf("SD mount failed: %u\n", (unsigned)result);
        halt();
    }

    result = f_open(&program_file, BOOT_FILENAME, FA_READ);
    if (result != FR_OK) {
        printf("Open failed: %u\n", (unsigned)result);
        halt();
    }

    file_size = f_size(&program_file);
    if (file_size == 0) {
        printf("Program file is empty\n");
        f_close(&program_file);
        halt();
    }

    if (file_size > (FSIZE_t)(PROGRAM_LOAD_LIMIT - PROGRAM_LOAD_ADDR)) {
        printf("Program is too large: %u bytes\n", (unsigned)file_size);
        f_close(&program_file);
        halt();
    }

    while (loaded < (uint32_t)file_size) {
        UINT bytes_read = 0;
        UINT requested = (UINT)((uint32_t)file_size - loaded);

        if (requested > COPY_CHUNK_BYTES) {
            requested = COPY_CHUNK_BYTES;
        }

        result = f_read(&program_file,
                        (void *)(uintptr_t)(PROGRAM_LOAD_ADDR + loaded),
                        requested,
                        &bytes_read);

        if (result != FR_OK || bytes_read != requested) {
            printf("Read failed at byte %u: FatFs=%u read=%u\n",
                   (unsigned)loaded, (unsigned)result,
                   (unsigned)bytes_read);
            f_close(&program_file);
            halt();
        }

        loaded += bytes_read;
    }

    f_close(&program_file);
    f_mount(NULL, "", 0);

    printf("Loaded %u bytes; starting program\n", (unsigned)loaded);
    start_program(PROGRAM_LOAD_ADDR);
}

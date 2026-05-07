// =============================================================================
// framebuffer.h
// 320x240 RGB565 framebuffer driver for the RISC-V soft-core.
// Backed by on-chip dual-port M10K RAM, scaled 2x to 640x480 by the VGA
// controller. CPU writes RGB565 pixels as normal memory stores; the VGA
// controller scans them out independently.
//
// Memory layout: pixels are packed two-per-word (little-endian halves).
//   word at FB_BASE + (y*160 + x/2)*4:
//     bits [15:0]  = pixel at (even_x,  y)
//     bits [31:16] = pixel at (even_x+1, y)
// =============================================================================
#ifndef FRAMEBUFFER_H
#define FRAMEBUFFER_H

#include <stdint.h>
#include <stddef.h>

// -------- Configuration ------------------------------------------------------
// FB_BASE must match the Graphics_Select region in your address_decoder.
#ifndef FB_BASE
#define FB_BASE   0x04040000
#endif

#define FB_W      320
#define FB_H      240
#define FB_PIXELS (FB_W * FB_H)
#define FB_BYTES  (FB_PIXELS * 2)

// -------- Common RGB565 colours ---------------------------------------------
#define FB_BLACK    0x0000u
#define FB_WHITE    0xFFFFu
#define FB_RED      0xF800u
#define FB_GREEN    0x07E0u
#define FB_BLUE     0x001Fu
#define FB_YELLOW   0xFFE0u
#define FB_CYAN     0x07FFu
#define FB_MAGENTA  0xF81Fu
#define FB_GRAY     0x8410u
#define FB_DKGRAY   0x4208u

// -------- Colour helpers -----------------------------------------------------
// Pack 8/8/8 RGB into RGB565.
static inline uint16_t fb_rgb(uint8_t r, uint8_t g, uint8_t b) {
    return (uint16_t)(((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3));
}

// -------- Raw access ---------------------------------------------------------
static inline volatile uint16_t *fb_pixels(void) {
    return (volatile uint16_t *)FB_BASE;
}

static inline volatile uint32_t *fb_pairs(void) {
    return (volatile uint32_t *)FB_BASE;
}

// -------- Drawing primitives -------------------------------------------------
// Single pixel, bounds-checked.
void fb_pixel(int x, int y, uint16_t c);

// Single pixel, no bounds check (for inner loops you've already clipped).
static inline void fb_pixel_fast(int x, int y, uint16_t c) {
    fb_pixels()[y * FB_W + x] = c;
}

// Fill the entire screen with one colour. Uses 32-bit stores (two pixels per
// store) for ~2x speedup vs naive byte/halfword loops.
void fb_clear(uint16_t c);

// Filled rectangle, clipped to screen. (x, y) is top-left, (w, h) is size.
void fb_fill_rect(int x, int y, int w, int h, uint16_t c);

// Horizontal and vertical line primitives (clipped).
void fb_hline(int x, int y, int w, uint16_t c);
void fb_vline(int x, int y, int h, uint16_t c);

// 1-pixel-wide rectangle outline.
void fb_rect(int x, int y, int w, int h, uint16_t c);

// Bresenham line (clipped per-pixel; fine for casual use).
void fb_line(int x0, int y0, int x1, int y1, uint16_t c);

// -------- BMP loader ---------------------------------------------------------
// Loads a 24-bit uncompressed BMP from a memory buffer and blits it at (x0,y0).
// Returns 0 on success, negative on format error.
//   -1 = not a BMP (bad magic)
//   -2 = unsupported bit depth (not 24)
//   -3 = unsupported compression
int fb_blit_bmp24(const uint8_t *bmp_data, size_t bmp_size, int x0, int y0);

#endif // FRAMEBUFFER_H
// =============================================================================
// framebuffer.h
// 320x240 RGB565 framebuffer driver for the RISC-V soft-core.
// Backed by SDRAM (top 8MB), scanned out and line-doubled to 640x480 by the
// vga_framebuffer_sdram controller. CPU writes RGB565 pixels as ordinary
// memory stores; the controller bursts each scanline into a line buffer.
//
// Memory layout (in SDRAM, addressed from the CPU's RAM window):
//   pixel (x, y) lives at:  FB_BASE + y*FB_STRIDE_BYTES + x*2   (RGB565)
//
//   ROW STRIDE IS 1024 BYTES (512 pixels), NOT 640.  The padding to a power
//   of two guarantees every 320-word line burst stays inside one SDRAM row.
//   Visible width is FB_W (320); the extra 192 pixels per row are off-screen.
// =============================================================================
#ifndef FRAMEBUFFER_H
#define FRAMEBUFFER_H
#include <stdint.h>
#include <stddef.h>
// -------- Configuration ------------------------------------------------------
// CPU-side framebuffer base.  Physical SDRAM 0x03800000 lives at CPU address
// RAM_BASE(0x08000000) + 0x03800000 = 0x0B800000.  The hardware fb_base MMIO
// register holds the *physical* 0x03800000; firmware uses the CPU address.
#ifndef FB_BASE
#define FB_BASE   0x0B800000u
#endif
#define FB_W            320              // visible width  (pixels)
#define FB_H            240              // visible height (rows)
#define FB_STRIDE       512              // pixels per row in memory (1024 bytes)
#define FB_STRIDE_BYTES (FB_STRIDE * 2)
#define FB_PIXELS       (FB_W * FB_H)        // visible pixel count
#define FB_WORDS        (FB_STRIDE * FB_H)   // total backing-store pixels (incl. pad)
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
void fb_pixel(int x, int y, uint16_t c);
static inline void fb_pixel_fast(int x, int y, uint16_t c) {
    fb_pixels()[y * FB_STRIDE + x] = c;
}
void fb_clear(uint16_t c);
void fb_fill_rect(int x, int y, int w, int h, uint16_t c);
void fb_hline(int x, int y, int w, uint16_t c);
void fb_vline(int x, int y, int h, uint16_t c);
void fb_rect(int x, int y, int w, int h, uint16_t c);
void fb_line(int x0, int y0, int x1, int y1, uint16_t c);
int  fb_blit_bmp24(const uint8_t *bmp_data, size_t bmp_size, int x0, int y0);
#endif // FRAMEBUFFER_H

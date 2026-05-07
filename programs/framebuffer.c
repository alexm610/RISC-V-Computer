// =============================================================================
// framebuffer.c
// Implementation of the 320x240 RGB565 framebuffer driver.
// =============================================================================
#include "framebuffer.h"
#include <string.h>

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------
static inline int clip_lo(int v, int lo) { return v < lo ? lo : v; }
static inline int clip_hi(int v, int hi) { return v > hi ? hi : v; }

// ---------------------------------------------------------------------------
// Single pixel (bounds-checked)
// ---------------------------------------------------------------------------
void fb_pixel(int x, int y, uint16_t c) {
    if ((unsigned)x >= FB_W || (unsigned)y >= FB_H) return;
    fb_pixels()[y * FB_W + x] = c;
}

// ---------------------------------------------------------------------------
// Full-screen clear. Two pixels per 32-bit store.
// ---------------------------------------------------------------------------
void fb_clear(uint16_t c) {
    volatile uint32_t *p = fb_pairs();
    uint32_t pair = ((uint32_t)c << 16) | c;
    int n = FB_PIXELS / 2;
    for (int i = 0; i < n; i++) {
        p[i] = pair;
    }
}

// ---------------------------------------------------------------------------
// Filled rectangle. Uses 32-bit pair stores on the aligned middle, falls back
// to 16-bit pixel stores on the unaligned edges.
// ---------------------------------------------------------------------------
void fb_fill_rect(int x, int y, int w, int h, uint16_t c) {
    // Clip to screen
    if (w <= 0 || h <= 0) return;
    int x0 = clip_lo(x, 0);
    int y0 = clip_lo(y, 0);
    int x1 = clip_hi(x + w, FB_W);   // exclusive
    int y1 = clip_hi(y + h, FB_H);   // exclusive
    if (x0 >= x1 || y0 >= y1) return;

    volatile uint16_t *fb = fb_pixels();
    uint32_t pair = ((uint32_t)c << 16) | c;

    for (int yy = y0; yy < y1; yy++) {
        int row = yy * FB_W;
        int xx = x0;

        // Handle leading unaligned pixel
        if (xx & 1) {
            fb[row + xx] = c;
            xx++;
        }
        // Aligned middle: 32-bit pair stores
        volatile uint32_t *prow = (volatile uint32_t *)&fb[row + xx];
        int pairs = (x1 - xx) >> 1;
        for (int i = 0; i < pairs; i++) {
            prow[i] = pair;
        }
        xx += pairs * 2;
        // Trailing unaligned pixel
        if (xx < x1) {
            fb[row + xx] = c;
        }
    }
}

// ---------------------------------------------------------------------------
// Horizontal / vertical lines
// ---------------------------------------------------------------------------
void fb_hline(int x, int y, int w, uint16_t c) {
    fb_fill_rect(x, y, w, 1, c);
}

void fb_vline(int x, int y, int h, uint16_t c) {
    fb_fill_rect(x, y, 1, h, c);
}

// ---------------------------------------------------------------------------
// 1-pixel rectangle outline
// ---------------------------------------------------------------------------
void fb_rect(int x, int y, int w, int h, uint16_t c) {
    if (w <= 0 || h <= 0) return;
    fb_hline(x,         y,         w, c);
    fb_hline(x,         y + h - 1, w, c);
    fb_vline(x,         y,         h, c);
    fb_vline(x + w - 1, y,         h, c);
}

// ---------------------------------------------------------------------------
// Bresenham's line algorithm. Clipped per-pixel.
// ---------------------------------------------------------------------------
void fb_line(int x0, int y0, int x1, int y1, uint16_t c) {
    int dx =  (x1 > x0) ? (x1 - x0) : (x0 - x1);
    int dy = -((y1 > y0) ? (y1 - y0) : (y0 - y1));
    int sx = (x0 < x1) ? 1 : -1;
    int sy = (y0 < y1) ? 1 : -1;
    int err = dx + dy;

    for (;;) {
        fb_pixel(x0, y0, c);
        if (x0 == x1 && y0 == y1) break;
        int e2 = err * 2;
        if (e2 >= dy) { err += dy; x0 += sx; }
        if (e2 <= dx) { err += dx; y0 += sy; }
    }
}

// ---------------------------------------------------------------------------
// BMP loader (24-bit uncompressed only).
// BMP header is little-endian; this code assumes a little-endian RISC-V
// target (which is the standard rv32 ABI).
// ---------------------------------------------------------------------------
typedef struct __attribute__((packed)) {
    uint16_t bf_type;        // 'BM' = 0x4D42
    uint32_t bf_size;
    uint16_t bf_rsvd1;
    uint16_t bf_rsvd2;
    uint32_t bf_off_bits;    // offset from file start to pixel data
    uint32_t bi_size;        // header size; expect 40 (BITMAPINFOHEADER)
    int32_t  bi_width;
    int32_t  bi_height;      // positive => bottom-up rows; negative => top-down
    uint16_t bi_planes;
    uint16_t bi_bit_count;
    uint32_t bi_compression; // 0 = BI_RGB
    uint32_t bi_size_image;
    int32_t  bi_x_ppm;
    int32_t  bi_y_ppm;
    uint32_t bi_clr_used;
    uint32_t bi_clr_important;
} bmp_header_t;

int fb_blit_bmp24(const uint8_t *bmp_data, size_t bmp_size, int x0, int y0) {
    if (bmp_size < sizeof(bmp_header_t)) return -1;

    bmp_header_t h;
    memcpy(&h, bmp_data, sizeof(h));

    if (h.bf_type != 0x4D42)        return -1;   // not "BM"
    if (h.bi_bit_count != 24)       return -2;
    if (h.bi_compression != 0)      return -3;
    if (h.bf_off_bits >= bmp_size)  return -1;

    int w = h.bi_width;
    int top_down = h.bi_height < 0;
    int h_abs = top_down ? -h.bi_height : h.bi_height;

    // BMP rows are padded to a 4-byte boundary
    int row_bytes = (w * 3 + 3) & ~3;
    const uint8_t *px_base = bmp_data + h.bf_off_bits;

    volatile uint16_t *fb = fb_pixels();

    for (int row = 0; row < h_abs; row++) {
        int src_row = top_down ? row : (h_abs - 1 - row);
        const uint8_t *src = px_base + src_row * row_bytes;
        int dy = y0 + row;
        if ((unsigned)dy >= FB_H) continue;

        // Bounds-check the source row stays inside the buffer
        if ((size_t)((src - bmp_data) + (size_t)w * 3) > bmp_size) break;

        int dy_off = dy * FB_W;
        for (int col = 0; col < w; col++) {
            int dx = x0 + col;
            if ((unsigned)dx >= FB_W) continue;
            // BMP stores pixels as B, G, R
            uint8_t b = src[col * 3 + 0];
            uint8_t g = src[col * 3 + 1];
            uint8_t r = src[col * 3 + 2];
            fb[dy_off + dx] = fb_rgb(r, g, b);
        }
    }
    return 0;
}
// =============================================================================
// framebuffer.c
// 320x240 RGB565 framebuffer driver (SDRAM-backed, 512-pixel row stride).
// =============================================================================
#include "framebuffer.h"
#include <string.h>

static inline int clip_lo(int v, int lo) { return v < lo ? lo : v; }
static inline int clip_hi(int v, int hi) { return v > hi ? hi : v; }

// ---------------------------------------------------------------------------
// Single pixel (bounds-checked). Note: addressing uses FB_STRIDE, clipping
// uses FB_W (the visible width).
// ---------------------------------------------------------------------------
void fb_pixel(int x, int y, uint16_t c) {
    if ((unsigned)x >= FB_W || (unsigned)y >= FB_H) return;
    fb_pixels()[y * FB_STRIDE + x] = c;
}

// ---------------------------------------------------------------------------
// Full-screen clear. Only the visible 320 pixels of each row are scanned out,
// so skip the off-screen stride padding and use aligned pair stores.
// ---------------------------------------------------------------------------
void fb_clear(uint16_t c) {
    volatile uint16_t *fb = fb_pixels();
    uint32_t pair = ((uint32_t)c << 16) | c;
    int pairs = FB_W / 2;
    for (int y = 0; y < FB_H; y++) {
        volatile uint32_t *row = (volatile uint32_t *)&fb[y * FB_STRIDE];
        for (int i = 0; i < pairs; i++) {
            row[i] = pair;
        }
    }
}

// ---------------------------------------------------------------------------
// Filled rectangle. 32-bit pair stores on the aligned middle, 16-bit stores
// on the unaligned edges. FB_STRIDE is even, so a row base is always 4-byte
// aligned and pair alignment depends only on the x parity handled below.
// ---------------------------------------------------------------------------
void fb_fill_rect(int x, int y, int w, int h, uint16_t c) {
    if (w <= 0 || h <= 0) return;
    int x0 = clip_lo(x, 0);
    int y0 = clip_lo(y, 0);
    int x1 = clip_hi(x + w, FB_W);   // exclusive
    int y1 = clip_hi(y + h, FB_H);   // exclusive
    if (x0 >= x1 || y0 >= y1) return;
    volatile uint16_t *fb = fb_pixels();
    uint32_t pair = ((uint32_t)c << 16) | c;
    for (int yy = y0; yy < y1; yy++) {
        int row = yy * FB_STRIDE;
        int xx = x0;
        if (xx & 1) {                // leading unaligned pixel
            fb[row + xx] = c;
            xx++;
        }
        volatile uint32_t *prow = (volatile uint32_t *)&fb[row + xx];
        int pairs = (x1 - xx) >> 1;  // aligned middle: 32-bit pair stores
        for (int i = 0; i < pairs; i++) {
            prow[i] = pair;
        }
        xx += pairs * 2;
        if (xx < x1) {               // trailing unaligned pixel
            fb[row + xx] = c;
        }
    }
}

void fb_hline(int x, int y, int w, uint16_t c) { fb_fill_rect(x, y, w, 1, c); }
void fb_vline(int x, int y, int h, uint16_t c) { fb_fill_rect(x, y, 1, h, c); }

void fb_rect(int x, int y, int w, int h, uint16_t c) {
    if (w <= 0 || h <= 0) return;
    fb_hline(x,         y,         w, c);
    fb_hline(x,         y + h - 1, w, c);
    fb_vline(x,         y,         h, c);
    fb_vline(x + w - 1, y,         h, c);
}

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

typedef struct __attribute__((packed)) {
    uint16_t bf_type;
    uint32_t bf_size;
    uint16_t bf_rsvd1;
    uint16_t bf_rsvd2;
    uint32_t bf_off_bits;
    uint32_t bi_size;
    int32_t  bi_width;
    int32_t  bi_height;
    uint16_t bi_planes;
    uint16_t bi_bit_count;
    uint32_t bi_compression;
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
    if (h.bf_type != 0x4D42)        return -1;
    if (h.bi_bit_count != 24)       return -2;
    if (h.bi_compression != 0)      return -3;
    if (h.bf_off_bits >= bmp_size)  return -1;
    int w = h.bi_width;
    if (w <= 0) return -1;
    int top_down = h.bi_height < 0;
    int h_abs = top_down ? -h.bi_height : h.bi_height;
    if (h_abs <= 0) return 0;
    int row_bytes = (w * 3 + 3) & ~3;
    const uint8_t *px_base = bmp_data + h.bf_off_bits;
    volatile uint16_t *fb = fb_pixels();
    int dst_x0 = clip_lo(x0, 0);
    int dst_x1 = clip_hi(x0 + w, FB_W);
    if (dst_x0 >= dst_x1) return 0;
    int src_col0 = dst_x0 - x0;
    for (int row = 0; row < h_abs; row++) {
        int src_row = top_down ? row : (h_abs - 1 - row);
        const uint8_t *src = px_base + src_row * row_bytes;
        int dy = y0 + row;
        if ((unsigned)dy >= FB_H) continue;
        if ((size_t)((src - bmp_data) + (size_t)w * 3) > bmp_size) break;
        volatile uint16_t *dst = &fb[dy * FB_STRIDE + dst_x0];
        const uint8_t *s = src + src_col0 * 3;
        int pixels = dst_x1 - dst_x0;
        if (dst_x0 & 1) {
            dst[0] = fb_rgb(s[2], s[1], s[0]);
            dst++;
            s += 3;
            pixels--;
        }
        volatile uint32_t *dst_pair = (volatile uint32_t *)dst;
        int pairs = pixels >> 1;
        for (int i = 0; i < pairs; i++) {
            uint16_t p0 = fb_rgb(s[2], s[1], s[0]);
            uint16_t p1 = fb_rgb(s[5], s[4], s[3]);
            dst_pair[i] = ((uint32_t)p1 << 16) | p0;
            s += 6;
        }
        if (pixels & 1) {
            dst[pairs * 2] = fb_rgb(s[2], s[1], s[0]);
        }
    }
    return 0;
}

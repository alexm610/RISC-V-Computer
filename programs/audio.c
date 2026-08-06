#include <stdio.h>
#include <stdint.h>
#include "audio.h"
#include "ff.h"
#include "instructions.h"
#include "uart.h"

#define AUDIO_CODEC_ADDR        0x1A
#define AUDIO_STREAM_BUF_SIZE   4096
#define AUDIO_PREFILL_SAMPLES   3584

static FIL g_audio_file;

__attribute__((aligned(4)))
static uint8_t g_audio_buf[AUDIO_STREAM_BUF_SIZE];

static void audio_delay(volatile unsigned count) {
    while (count--) {
    }
}

static uint16_t rd16(const uint8_t *p) {
    return (uint16_t)p[0] | ((uint16_t)p[1] << 8);
}

static uint32_t rd32(const uint8_t *p) {
    return (uint32_t)p[0]
         | ((uint32_t)p[1] << 8)
         | ((uint32_t)p[2] << 16)
         | ((uint32_t)p[3] << 24);
}

static int fourcc_eq(const uint8_t *p, char a, char b, char c, char d) {
    return p[0] == (uint8_t)a && p[1] == (uint8_t)b &&
           p[2] == (uint8_t)c && p[3] == (uint8_t)d;
}

static int audio_i2c_wait(void) {
    unsigned long guard = 200000UL;

    while ((AUDIO_I2C_STATUS & (AUDIO_I2C_TIP | AUDIO_I2C_BUSY)) && guard--) {
    }

    return guard ? AUDIO_OK : AUDIO_ERR_CODEC;
}

static int audio_i2c_tx(uint8_t byte, uint32_t command) {
    AUDIO_I2C_DATA = byte;
    AUDIO_I2C_COMMAND = command | AUDIO_I2C_WRITE;

    if (audio_i2c_wait() != AUDIO_OK) {
        return AUDIO_ERR_CODEC;
    }

    return (AUDIO_I2C_STATUS & AUDIO_I2C_RX_ACK) ? AUDIO_ERR_CODEC : AUDIO_OK;
}

void audio_init(void) {
    AUDIO_I2C_PRESCALE = 250; /* ~100 kHz I2C from 50 MHz bus clock */
    AUDIO_I2C_CONTROL = AUDIO_I2C_ENABLE;
    AUDIO_I2S_CONTROL = AUDIO_I2S_CLEAR_FIFO | AUDIO_I2S_CLEAR_UNDERRUN;
    AUDIO_I2S_CONTROL = 0;
    audio_delay(500000UL);
}

int audio_i2c_write_reg(uint8_t device_addr, uint8_t reg, uint16_t value) {
    uint8_t first = (uint8_t)((reg << 1) | ((value >> 8) & 0x01));
    uint8_t second = (uint8_t)(value & 0xFF);

    if (audio_i2c_tx((uint8_t)(device_addr << 1), AUDIO_I2C_START) != AUDIO_OK) {
        return AUDIO_ERR_CODEC;
    }

    if (audio_i2c_tx(first, 0) != AUDIO_OK) {
        return AUDIO_ERR_CODEC;
    }

    return audio_i2c_tx(second, AUDIO_I2C_STOP);
}

int audio_codec_init(void) {
    static const struct {
        uint8_t reg;
        uint16_t value;
    } init_seq[] = {
        {15, 0x000}, /* reset */
        {0,  0x017}, /* left line in */
        {1,  0x017}, /* right line in */
        {2,  0x070}, /* left headphone out */
        {3,  0x070}, /* right headphone out */
        {4,  0x012}, /* DAC selected, line input */
        {5,  0x000}, /* no deemphasis */
        {6,  0x000}, /* power on */
        {7,  0x003}, /* DSP mode A, 16-bit, codec slave */
        {8,  0x000}, /* normal mode, 48 kHz with 12.288 MHz XCK */
        {9,  0x001}  /* activate */
    };

    for (unsigned i = 0; i < sizeof(init_seq) / sizeof(init_seq[0]); i++) {
        if (audio_i2c_write_reg(AUDIO_CODEC_ADDR, init_seq[i].reg, init_seq[i].value) != AUDIO_OK) {
            printf("\r\nAudio codec init failed at reg %u.", init_seq[i].reg);
            return AUDIO_ERR_CODEC;
        }

        if (init_seq[i].reg == 15) {
            audio_delay(2500000UL);
        } else {
            audio_delay(50000UL);
        }
    }

    printf("\r\nAudio codec init OK.");
    return AUDIO_OK;
}

static int parse_wav(FIL *file, audio_wav_info_t *info) {
    uint8_t hdr[12];
    UINT br = 0;
    FRESULT res;
    int have_fmt = 0;
    int have_data = 0;

    res = f_read(file, hdr, sizeof(hdr), &br);
    if (res != FR_OK || br != sizeof(hdr)) {
        return AUDIO_ERR_READ;
    }

    if (!fourcc_eq(hdr, 'R', 'I', 'F', 'F') || !fourcc_eq(hdr + 8, 'W', 'A', 'V', 'E')) {
        return AUDIO_ERR_FORMAT;
    }

    while (!have_data) {
        uint8_t chunk[8];
        uint32_t chunk_size;
        FSIZE_t chunk_data_pos;

        res = f_read(file, chunk, sizeof(chunk), &br);
        if (res != FR_OK || br != sizeof(chunk)) {
            return AUDIO_ERR_READ;
        }

        chunk_size = rd32(chunk + 4);
        chunk_data_pos = f_tell(file);

        if (fourcc_eq(chunk, 'f', 'm', 't', ' ')) {
            uint8_t fmt[16];

            if (chunk_size < sizeof(fmt)) {
                return AUDIO_ERR_FORMAT;
            }

            res = f_read(file, fmt, sizeof(fmt), &br);
            if (res != FR_OK || br != sizeof(fmt)) {
                return AUDIO_ERR_READ;
            }

            info->audio_format = rd16(fmt + 0);
            info->channels = rd16(fmt + 2);
            info->sample_rate = rd32(fmt + 4);
            info->byte_rate = rd32(fmt + 8);
            info->block_align = rd16(fmt + 12);
            info->bits_per_sample = rd16(fmt + 14);
            have_fmt = 1;
        } else if (fourcc_eq(chunk, 'd', 'a', 't', 'a')) {
            if (!have_fmt) {
                return AUDIO_ERR_FORMAT;
            }

            info->data_offset = (uint32_t)chunk_data_pos;
            info->data_size = chunk_size;
            have_data = 1;
            break;
        }

        res = f_lseek(file, chunk_data_pos + chunk_size + (chunk_size & 1U));
        if (res != FR_OK) {
            return AUDIO_ERR_READ;
        }
    }

    return have_data ? AUDIO_OK : AUDIO_ERR_FORMAT;
}

int audio_get_wav_info(const char *path, audio_wav_info_t *info) {
    FRESULT res;
    int rc;

    if (!info) {
        return AUDIO_ERR_FORMAT;
    }

    res = f_open(&g_audio_file, path, FA_READ);
    if (res != FR_OK) {
        return AUDIO_ERR_OPEN;
    }

    rc = parse_wav(&g_audio_file, info);
    f_close(&g_audio_file);
    return rc;
}

static uint32_t wav_sample_to_i2s_word(const uint8_t *p, const audio_wav_info_t *info) {
    int16_t left = 0;
    int16_t right = 0;

    if (info->bits_per_sample == 16) {
        left = (int16_t)rd16(p);
        right = (info->channels == 2) ? (int16_t)rd16(p + 2) : left;
    } else {
        left = (int16_t)(((int)p[0] - 128) << 8);
        right = (info->channels == 2) ? (int16_t)(((int)p[1] - 128) << 8) : left;
    }

    return ((uint32_t)(uint16_t)left << 16) | (uint16_t)right;
}

void audio_play_test_tone(unsigned frequency_hz, unsigned duration_ms) {
    uint32_t total_samples = (48000UL * duration_ms) / 1000UL;
    uint32_t phase = 0;
    uint32_t phase_step;
    unsigned prefilled_samples = 0;
    int started = 0;

    if (frequency_hz == 0 || duration_ms == 0) {
        return;
    }

    phase_step = (uint32_t)(((uint64_t)frequency_hz << 32) / 48000UL);

    printf("\r\nAudio tone: %u Hz, %u ms", frequency_hz, duration_ms);

    AUDIO_I2S_CONTROL = AUDIO_I2S_CLEAR_FIFO | AUDIO_I2S_CLEAR_UNDERRUN;
    AUDIO_I2S_CONTROL = 0;

    for (uint32_t i = 0; i < total_samples; i++) {
        int16_t sample = (phase & 0x80000000UL) ? 0x4000 : -0x4000;
        uint32_t word = ((uint32_t)(uint16_t)sample << 16) | (uint16_t)sample;

        while ((AUDIO_I2S_STATUS & AUDIO_I2S_TX_READY) == 0) {
        }

        AUDIO_I2S_TXDATA = word;
        phase += phase_step;

        if (!started) {
            prefilled_samples++;

            if (prefilled_samples >= AUDIO_PREFILL_SAMPLES) {
                AUDIO_I2S_CONTROL = AUDIO_I2S_ENABLE | AUDIO_I2S_CLEAR_UNDERRUN;
                started = 1;
            }
        }
    }

    if (!started) {
        AUDIO_I2S_CONTROL = AUDIO_I2S_ENABLE | AUDIO_I2S_CLEAR_UNDERRUN;
    }

    while ((AUDIO_I2S_STATUS & AUDIO_I2S_TX_EMPTY) == 0) {
    }

    audio_delay(2000000UL);

    AUDIO_I2S_CONTROL = AUDIO_I2S_CLEAR_UNDERRUN;

    if (AUDIO_I2S_STATUS & AUDIO_I2S_UNDERRUN) {
        printf("\r\nAudio tone underrun detected.");
    }

    printf("\r\nAudio tone status: %u", (unsigned)AUDIO_I2S_STATUS);
}

int audio_play_wav(const char *path) {
    audio_wav_info_t info;
    FRESULT res;
    UINT br = 0;
    uint32_t remaining;
    unsigned prefilled_samples = 0;
    unsigned sample_step = 1;
    unsigned sample_skip = 1;
    int started = 0;

    printf("\r\nOpening audio '%s'...\r\n", path);
    res = f_open(&g_audio_file, path, FA_READ);
    if (res != FR_OK) {
        printf("\r\nf_open failed: %d", res);
        return AUDIO_ERR_OPEN;
    }

    int rc = parse_wav(&g_audio_file, &info);
    if (rc != AUDIO_OK) {
        printf("\r\nInvalid WAV: %d", rc);
        f_close(&g_audio_file);
        return rc;
    }

    printf("\r\nWAV: %u Hz, %u ch, %u bits, %u bytes",
           (unsigned)info.sample_rate,
           (unsigned)info.channels,
           (unsigned)info.bits_per_sample,
           (unsigned)info.data_size);

    if (info.audio_format != 1 ||
        (info.channels != 1 && info.channels != 2) ||
        (info.bits_per_sample != 8 && info.bits_per_sample != 16)) {
        printf("\r\nUnsupported WAV. Use PCM, 8/16-bit, mono/stereo.");
        f_close(&g_audio_file);
        return AUDIO_ERR_UNSUPPORTED;
    }

    if (info.sample_rate == 48000UL) {
        sample_step = 1;
    } else if (info.sample_rate == 96000UL) {
        sample_step = 2;
        printf("\r\nDownsampling 96 kHz WAV to 48 kHz.");
    } else if (info.sample_rate == 192000UL) {
        sample_step = 4;
        printf("\r\nDownsampling 192 kHz WAV to 48 kHz.");
    } else {
        printf("\r\nUnsupported sample rate. Use 48 kHz PCM, or 96/192 kHz PCM for simple downsampling.");
        f_close(&g_audio_file);
        return AUDIO_ERR_UNSUPPORTED;
    }

    sample_skip = sample_step * info.block_align;

    res = f_lseek(&g_audio_file, info.data_offset);
    if (res != FR_OK) {
        f_close(&g_audio_file);
        return AUDIO_ERR_READ;
    }

    AUDIO_I2S_CONTROL = AUDIO_I2S_CLEAR_FIFO | AUDIO_I2S_CLEAR_UNDERRUN;
    AUDIO_I2S_CONTROL = 0;

    remaining = info.data_size;

    while (remaining > 0) {
        UINT want = (remaining > sizeof(g_audio_buf)) ? sizeof(g_audio_buf) : (UINT)remaining;
        UINT used = 0;

        want -= want % info.block_align;
        if (want == 0) {
            break;
        }

        res = f_read(&g_audio_file, g_audio_buf, want, &br);
        if (res != FR_OK) {
            printf("\r\nf_read failed: %d", res);
            f_close(&g_audio_file);
            return AUDIO_ERR_READ;
        }

        if (br == 0) {
            break;
        }

        UINT bytes_read = br;
        UINT processable = br - (br % sample_skip);

        while (used < processable) {
            while ((AUDIO_I2S_STATUS & AUDIO_I2S_TX_READY) == 0) {
            }

            AUDIO_I2S_TXDATA = wav_sample_to_i2s_word(g_audio_buf + used, &info);
            used += sample_skip;

            if (!started) {
                prefilled_samples++;

                if (prefilled_samples >= AUDIO_PREFILL_SAMPLES) {
                    AUDIO_I2S_CONTROL = AUDIO_I2S_ENABLE | AUDIO_I2S_CLEAR_UNDERRUN;
                    started = 1;
                }
            }
        }

        remaining -= bytes_read;
    }

    if (!started) {
        AUDIO_I2S_CONTROL = AUDIO_I2S_ENABLE | AUDIO_I2S_CLEAR_UNDERRUN;
    }

    if (AUDIO_I2S_STATUS & AUDIO_I2S_UNDERRUN) {
        printf("\r\nAudio underrun detected.");
    }

    printf("\r\nAudio status: %u", (unsigned)AUDIO_I2S_STATUS);

    f_close(&g_audio_file);
    printf("\r\nAudio done.\r\n");
    return AUDIO_OK;
}

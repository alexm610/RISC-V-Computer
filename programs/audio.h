#ifndef AUDIO_H
#define AUDIO_H

#include <stdint.h>

#define AUDIO_OK                    0
#define AUDIO_ERR_OPEN             -1
#define AUDIO_ERR_READ             -2
#define AUDIO_ERR_FORMAT           -3
#define AUDIO_ERR_UNSUPPORTED      -4
#define AUDIO_ERR_CODEC            -5

typedef struct {
    uint16_t audio_format;
    uint16_t channels;
    uint32_t sample_rate;
    uint32_t byte_rate;
    uint16_t block_align;
    uint16_t bits_per_sample;
    uint32_t data_offset;
    uint32_t data_size;
} audio_wav_info_t;

void audio_init(void);
int audio_codec_init(void);
void audio_play_test_tone(unsigned frequency_hz, unsigned duration_ms);
int audio_play_wav(const char *path);
int audio_get_wav_info(const char *path, audio_wav_info_t *info);
int audio_i2c_write_reg(uint8_t device_addr, uint8_t reg, uint16_t value);

#endif /* AUDIO_H */

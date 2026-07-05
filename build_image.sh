#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: ./build_image.sh INPUT_IMAGE [OUTPUT_BMP]

Converts INPUT_IMAGE to the 320x240 uncompressed 24bpp BMP format expected by
fb_blit_bmp24(). If OUTPUT_BMP is omitted, the output is INPUT_IMAGE with a
.bmp extension.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

if [[ $# -lt 1 || $# -gt 2 ]]; then
    usage >&2
    exit 1
fi

if ! command -v convert >/dev/null 2>&1; then
    echo "error: ImageMagick 'convert' command was not found." >&2
    exit 1
fi

input=$1
if [[ ! -f "$input" ]]; then
    echo "error: input image not found: $input" >&2
    exit 1
fi

if [[ $# -eq 2 ]]; then
    output=$2
else
    base=${input%.*}
    output="${base}.bmp"
fi

convert "$input" -resize 320x240! -type TrueColor -depth 8 "BMP3:$output"

echo "Wrote $output"
if command -v file >/dev/null 2>&1; then
    file "$output"
fi

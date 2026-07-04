#!/usr/bin/env bash
set -euo pipefail

START_TIME=$(date +%s)

PROJECT="risc_v_core"
REVISION="risc_v_core"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROGRAMS_DIR="${ROOT_DIR}/programs"
SOURCE_DIR="${ROOT_DIR}/source"
SOF_FILE="${SOURCE_DIR}/output_files/${PROJECT}.sof"
FLASH_DEVICE_INDEX="${FLASH_DEVICE_INDEX:-2}"

format_duration() {
    local total_seconds="$1"
    local hours=$((total_seconds / 3600))
    local minutes=$(((total_seconds % 3600) / 60))
    local seconds=$((total_seconds % 60))

    if (( hours > 0 )); then
        printf "%dh %02dm %02ds" "${hours}" "${minutes}" "${seconds}"
    elif (( minutes > 0 )); then
        printf "%dm %02ds" "${minutes}" "${seconds}"
    else
        printf "%ds" "${seconds}"
    fi
}

finish() {
    local status=$?
    local end_time
    local elapsed

    end_time=$(date +%s)
    elapsed=$((end_time - START_TIME))

    if (( status == 0 )); then
        echo "==> Done in $(format_duration "${elapsed}")"
    else
        echo "==> Failed after $(format_duration "${elapsed}")" >&2
    fi

    exit "${status}"
}

trap finish EXIT

usage() {
    cat <<USAGE
Usage:
  ./compile.sh           Build programs/instructions.mif and run full Quartus compile
  ./compile.sh --update  Build programs/instructions.mif and update only the .sof MIF contents
  ./compile.sh --flash   Program the existing .sof to JTAG device ${FLASH_DEVICE_INDEX}
  ./compile.sh --help    Show this help

Notes:
  --update expects a previous successful full Quartus compile/fitter run.
  --flash expects ${SOF_FILE} to exist.
  Set FLASH_DEVICE_INDEX to override the JTAG chain device index.
USAGE
}

case "${1:-}" in
    "")
        MODE="full"
        ;;
    --update)
        MODE="update"
        ;;
    --flash)
        MODE="flash"
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    *)
        echo "Unknown option: $1" >&2
        usage >&2
        exit 2
        ;;
esac

if [[ "${MODE}" == "full" ]]; then
    echo "==> Building program image"
    make -C "${PROGRAMS_DIR}"

    echo "==> Running full Quartus compile"
    cd "${SOURCE_DIR}"
    quartus_sh --flow compile "${PROJECT}"
elif [[ "${MODE}" == "update" ]]; then
    echo "==> Building program image"
    make -C "${PROGRAMS_DIR}"

    echo "==> Updating MIF contents in existing Quartus database"
    cd "${SOURCE_DIR}"
    quartus_cdb "${PROJECT}" -c "${REVISION}" --update_mif

    echo "==> Rebuilding assembler output (.sof)"
    quartus_asm "${PROJECT}" -c "${REVISION}"
else
    if [[ ! -f "${SOF_FILE}" ]]; then
        echo "Missing SOF file: ${SOF_FILE}" >&2
        echo "Run ./compile.sh first, or ./compile.sh --update after a previous full compile." >&2
        exit 1
    fi

    echo "==> Flashing ${SOF_FILE} over JTAG device ${FLASH_DEVICE_INDEX}"
    quartus_pgm --mode=JTAG -o "p;${SOF_FILE}@${FLASH_DEVICE_INDEX}"
fi

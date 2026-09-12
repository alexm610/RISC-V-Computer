#!/usr/bin/env bash
set -euo pipefail

# Run from any directory. Override tools if they are not on PATH.
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$(mktemp -d "${TMPDIR:-/tmp}/ram-exec.XXXXXX")"
trap 'rm -rf "$BUILD_DIR"' EXIT
CC="${CC:-riscv32-unknown-elf-gcc}"
OBJCOPY="${OBJCOPY:-riscv32-unknown-elf-objcopy}"
IVERILOG="${IVERILOG:-iverilog}"
VVP="${VVP:-vvp}"

"$CC" -march=rv32i_zicsr -mabi=ilp32 -mno-relax -nostdlib \
    -T "$ROOT_DIR/testbenches/ram_exec.ld" \
    "$ROOT_DIR/testbenches/ram_exec.s" -o "$BUILD_DIR/program.elf"
"$OBJCOPY" -O binary "$BUILD_DIR/program.elf" "$BUILD_DIR/program.bin"
python3 - "$BUILD_DIR" <<'PY'
import pathlib
import sys
root = pathlib.Path(sys.argv[1])
data = (root / 'program.bin').read_bytes()
assert len(data) <= 8192
(root / 'program.hex').write_text(''.join(f'{b:02x}\n' for b in data.ljust(8192, b'\0')))
PY

"$IVERILOG" -g2012 -s tb_ram_exec -I "$ROOT_DIR/source" \
    -o "$BUILD_DIR/simulation" \
    "$ROOT_DIR/testbenches/tb_ram_exec.sv" \
    "$ROOT_DIR/source/cpu.sv" "$ROOT_DIR/source/datapath.sv" \
    "$ROOT_DIR/source/reg_file.sv" "$ROOT_DIR/source/alu.sv" \
    "$ROOT_DIR/source/csr.sv" "$ROOT_DIR/source/address_decoder.sv" \
    "$ROOT_DIR/source/risc_v_core.sv" "$ROOT_DIR/source/sdram_mmu.sv"
for latency in 0 3 17; do
    "$VVP" "$BUILD_DIR/simulation" "+image=$BUILD_DIR/program.hex" "+latency=$latency"
done

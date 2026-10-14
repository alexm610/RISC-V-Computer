Run `./testbenches/run_ram_exec.sh` from the repository root. It requires
Icarus Verilog (`iverilog` and `vvp`), Python 3, and the existing
`riscv32-unknown-elf` GCC/objcopy toolchain. Tool paths can be overridden with
`IVERILOG`, `VVP`, `CC`, and `OBJCOPY`. All build products go into a temporary
directory and are removed on exit.

The test runs the real CPU, address decoder, read-data multiplexer, and
`sdram_mmu`. A test-only 16-bit controller supplies variable wait states and
holds acknowledgement until the request is released. ROM reads occur on the
falling clock edge, matching the on-chip ROM wrapper.

The ROM program copies its application into initially zeroed RAM, calls it,
and checks a successful return to ROM. The application exercises word, byte,
and halfword accesses (including signed/unsigned loads), reads its own code
as data, and takes interrupts into both ROM and RAM before returning with
`mret`. The call also checks `jalr` with the same base/link register and an
odd target whose low bit must be cleared.

Additional interrupts are injected when ADDI, LUI, JAL, JALR, CSRRS, and a RAM
load retire. These cases check that the completed register value survives
interrupt entry, the ISR runs once, and `mepc`/`mret` preserve the correct next
PC, including jump targets. Writeback controls must stay cleared while the RAM
interrupt-vector fetch waits for acknowledgement.

Bus assertions check full-word instruction fetches, stable requests through
wait states, instruction capture only on acknowledgement, and request release
before the next transaction. Three latency settings are tested.

This is an RTL integration regression; it does not model SDRAM pin timing,
refresh, or framebuffer bursts. FPGA timing closure and board testing remain
separate checks.

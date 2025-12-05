# Asylum Component: Timer

## Table of Contents

- **Introduction**: brief description of the repository
- **HDL Modules**: detailed description of each module in `hdl/` with generics and ports
- **CSR Register Map**: register summary (from `hdl/csr/*.hjson` and `hdl/csr/*.md`)
- **Verification**: how to run the testbench and FuseSoC core information

## Introduction

This repository contains a small timer IP (Asylum Project) implemented in VHDL. The component exposes a simple bus-accessible register map (CSR) and an optional interrupt output. The main sources are under the `hdl/` directory, CSR descriptions and generated files under `hdl/csr/`, and a functional testbench under `sim/`.

Key features:

- Byte-addressable counter registers (4 bytes)
- Control register supporting enable, autostart and tick/clock modes
- Optional interrupt generation and mask/status registers
- Simple SBI wrapper (`sbi_timer`) that connects the CSR interface to the timer core

## HDL Modules

This section documents the VHDL modules present in `hdl/`. For each entity the generics (when present) and ports are listed.

- `hdl/sbi_timer.vhd`

	Description: top-level wrapper that connects the SBI CSR block to the timer core. It instantiates the generated `timer_registers` CSR block and the `timer` core.

	Ports:

	| Name | Direction | Type | Description |
	|------|-----------|------|-------------|
	| `clk_i` | in | `std_logic` | Clock input |
	| `arst_b_i` | in | `std_logic` | Asynchronous reset (active low) |
	| `sbi_ini_i` | in | `sbi_ini_t` | SBI input interface (bus) |
	| `sbi_tgt_o` | out | `sbi_tgt_t` | SBI target output interface (bus) |
	| `timer_disable_i` | in | `std_logic` | External disable signal |
	| `timer_clear_i` | in | `std_logic` | External clear/reset request |
	| `it_o` | out | `std_logic` | Interrupt output to interrupt controller |

	Functionality: The `sbi_timer` is a glue module that maps bus transactions to the CSR block (`timer_registers`) and passes control/status to the `timer` core through structured signals (`timer_sw2hw_t` and `timer_hw2sw_t`).

- `hdl/timer_core.vhd` (entity name: `timer`)

	Description: pure timer core implementing the counting, control logic and a small GIC interface for interrupt signalling. This component expects the control/status values to be provided through the `sw2hw`/`hw2sw` records.

	Ports:

	| Name | Direction | Type | Description |
	|------|-----------|------|-------------|
	| `clk_i` | in | `std_logic` | Clock input |
	| `arst_b_i` | in | `std_logic` | Asynchronous reset (active low) |
	| `timer_disable_i` | in | `std_logic` | External disable signal |
	| `timer_clear_i` | in | `std_logic` | External clear | 
	| `it_o` | out | `std_logic` | Interrupt output |
	| `sw2hw_i` | in | `timer_sw2hw_t` | Control/status record from CSR block |
	| `hw2sw_o` | out | `timer_hw2sw_t` | Status record going back to CSR block |

	Functionality: The `timer` core builds a 32-bit counter from 4 bytes coming from CSR registers, counts down according to either the raw clock or a tick divider, controls enable/autostart logic, and drives interrupt/ISR fields via the `hw2sw_o` record. The core exposes internal signals such as `timer_init`, `timer_cnt_r`, and generates `timer_done` when the counter hits zero. It uses an instance of a GIC core to convert internal event signals into `it_o`.

- `hdl/timer_v1.vhd` (entity name: `timer_v1`)

	Description: bus-accessible register-level implementation of the timer. This is the register-transfer-level IP that implements the CSR registers accessible by a host bus (size configurable by generics).

	Generics:

	| Generic | Type | Default | Description |
	|---------|------|---------|-------------|
	| `TICK` | positive | `1000` | Divider value used when tick mode is enabled (number of clock cycles per tick) |
	| `SIZE_ADDR` | natural | `3` | Bus address width (in bytes / addressable locations) |
	| `SIZE_DATA` | natural | `8` | Bus data width (bits per transfer) |
	| `IT_ENABLE` | boolean | `false` | Enable interrupt generation support |

	Ports:

	| Name | Direction | Type | Description |
	|------|-----------|------|-------------|
	| `clk_i` | in | `std_logic` | Clock |
	| `cke_i` | in | `std_logic` | Clock enable (Gated/active cycle) |
	| `arstn_i` | in | `std_logic` | Active-low asynchronous reset |
	| `cs_i` | in | `std_logic` | Chip select / enable for bus access |
	| `re_i` | in | `std_logic` | Read enable |
	| `we_i` | in | `std_logic` | Write enable |
	| `addr_i` | in | `std_logic_vector(SIZE_ADDR-1 downto 0)` | Address bus |
	| `wdata_i` | in | `std_logic_vector(SIZE_DATA-1 downto 0)` | Write data |
	| `rdata_o` | out | `std_logic_vector(SIZE_DATA-1 downto 0)` | Read data |
	| `busy_o` | out | `std_logic` | Busy (unused, driven `'0'`) |
	| `interrupt_o` | out | `std_logic` | Interrupt output |
	| `interrupt_ack_i` | in | `std_logic` | Interrupt acknowledge input |

	Functionality: `timer_v1` implements the register map documented in the CSR files. Main registers include:

	- `status` (read): contains the event bit that is cleared on read.
	- `control` (read/write): fields for clear, enable, autostart, tick/clock selection.
	- `timer_byte[0..3]` (read/write): 4 bytes composing the 32-bit initial counter value.

	The implementation supports various data bus sizes (`SIZE_DATA` = 8, 16, 32) via VHDL generate blocks and packs/unpacks the 32-bit counter accordingly.

- `hdl/timer_pkg.vhd`

	Description: package that contains component declarations for `timer_v1`, `timer`, and `sbi_timer`. It is used by the testbench and higher level wrappers. See the file `hdl/timer_pkg.vhd` for the component interfaces.

	The `timer_v1` component declaration inside the package lists the generics and ports (see `timer_v1` section).

## CSR Register Map

The register map is described in `hdl/csr/timer.hjson` and more human-readable documentation in `hdl/csr/timer_csr.md`.

Summary of registers (from `hdl/csr/timer.hjson`):

| Address | Register | Description | Docs |
|--------:|---------:|-------------|------|
| `0x0` | `isr` | Interruption Status Register | [MD](hdl/csr/timer_csr.md#0x0-isr) · [HJSON](hdl/csr/timer.hjson) |
| `0x1` | `imr` | Interruption Mask Register | [MD](hdl/csr/timer_csr.md#0x1-imr) · [HJSON](hdl/csr/timer.hjson) |
| `0x2` | `control` | Control Timer | [MD](hdl/csr/timer_csr.md#0x2-control) · [HJSON](hdl/csr/timer.hjson) |
| `0x4` | `timer_byte0` | Timer Init Value byte 0 | [MD](hdl/csr/timer_csr.md#0x4-timer_byte0) · [HJSON](hdl/csr/timer.hjson) |
| `0x5` | `timer_byte1` | Timer Init Value byte 1 | [MD](hdl/csr/timer_csr.md#0x5-timer_byte1) · [HJSON](hdl/csr/timer.hjson) |
| `0x6` | `timer_byte2` | Timer Init Value byte 2 | [MD](hdl/csr/timer_csr.md#0x6-timer_byte2) · [HJSON](hdl/csr/timer.hjson) |
| `0x7` | `timer_byte3` | Timer Init Value byte 3 | [MD](hdl/csr/timer_csr.md#0x7-timer_byte3) · [HJSON](hdl/csr/timer.hjson) |

Notes:

- The `timer_csr.md` file contains a complete human-readable description of each register and its bitfields. Follow the links in the table to jump to per-register documentation.
- The canonical CSR source is `hdl/csr/timer.hjson`. The FuseSoC generator (`regtool`) uses this HJSON to generate VHDL and header files placed in `hdl/csr/`.

## Verification

A functional testbench is provided in `sim/tb_timer.vhd`. The FuseSoC core file `timer.core` (at repository root) defines the component and a `sim_basic` target that includes the testbench.


The testbench (`sim/tb_timer.vhd`) demonstrates common usage scenarios:

- Writing the counter bytes and starting the timer
- Using autostart mode
- Using tick mode (divider-based timing)

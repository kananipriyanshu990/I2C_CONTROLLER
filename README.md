# I²C Master-Slave Controller | Verilog RTL

A modular I²C communication controller designed using Verilog HDL. This project implements the fundamental building blocks of an I²C interface, including clock generation, master-side transmission and reception, slave-side data handling, and ACK/NACK management.

The design focuses on understanding and implementing serial communication at the RTL level through finite state machines, shift registers, counters, and synchronous control logic.

## Project Overview

The controller is designed around the following operating specifications:

| Specification | Configuration |
|---|---|
| Protocol | I²C |
| Operating Mode | Standard Mode |
| System Clock | 100 MHz |
| I²C Clock (SCL) | 100 kHz |
| Addressing | 7-bit |
| Data Width | 8-bit |
| Reset | Active-low asynchronous reset |
| HDL | Verilog |
| Testbench Language | SystemVerilog |

## Architecture

The project is divided into six independent RTL modules.

| Module | Description |
|---|---|
| `I2C_CLOCK_GENERATOR` | Generates the 100 kHz SCL clock and timing tick from the 100 MHz system clock. |
| `I2C_MASTER` | Implements the master-side control FSM for START, address transmission, data transmission, ACK reception, and STOP operations. |
| `I2CRECEIVER` | Receives 8-bit serial data from the slave and handles master ACK/NACK generation. |
| `I2C_SLAVE` | Implements slave address recognition and incoming data reception. |
| `I2C_TRANSMITTER` | Handles serial data transmission from the slave to the master. |
| `I2C_CONTROLLER` | Integrates slave-side address detection, read/write handling, data reception, data transmission, and acknowledgment control. |

## I²C Protocol Implementation

The design follows the basic I²C communication sequence:

1. **START Condition:** The master initiates communication by pulling SDA low while SCL is high.
2. **Address Transmission:** The 7-bit slave address is transmitted, followed by the R/W bit.
3. **Acknowledgment:** The addressed slave responds with ACK or NACK.
4. **Data Transfer:** Data is transferred in 8-bit frames, MSB first.
5. **ACK/NACK Handling:** The receiving device acknowledges each transferred byte.
6. **STOP Condition:** The master terminates communication by releasing SDA high while SCL is high.

Both master-side and slave-side data handling are implemented as separate RTL blocks.

## Design Features

- Modular RTL architecture.
- Finite State Machine (FSM)-based control logic.
- 7-bit slave addressing.
- 8-bit serial data transfer.
- MSB-first data transmission and reception.
- ACK/NACK handling.
- Separate master and slave data paths.
- Active-low asynchronous reset.
- Clock generation using a programmable counter-based divider architecture.

## Verification Approach

SystemVerilog testbenches are used to stimulate the individual RTL modules.

The verification approach focuses on waveform-based functional observation using simulation tools such as:

- **Icarus Verilog** – RTL compilation and simulation.
- **GTKWave** – Signal waveform inspection.
- **Vivado Simulator** – RTL simulation and debugging.

Important signals to observe include:

- `SCL` and `SCL_TICK`
- `SDA_IN`, `SDA_OUT`, and `SDA_OE`
- `DATA_IN` and `DATA_OUT`
- `DATA_VALID`
- `BUSY` and `DONE`
- ACK/NACK status signals

## Design Conventions

- Verilog HDL for synthesizable RTL.
- SystemVerilog for testbench development.
- Fixed-width counters and registers.
- Active-low reset (`RST_N`).
- Modular implementation with independent functional blocks.

The SDA interface uses an output-enable convention: asserting `SDA_OE` pulls the open-drain bus low, while deasserting it releases the bus. An external pull-up is required for the physical I²C interface.

## Project Status

**RTL module development:** Completed for the six planned modules.

**Verification:** Individual waveform-based testbench development and inspection.

**Integration:** Top-level integration and comprehensive protocol verification remain separate follow-up stages.

## Learning Outcomes

This project provides practical experience in:

- Designing FSM-based serial communication controllers.
- Implementing clock dividers and timing control.
- Understanding I²C START, STOP, ACK, and NACK conditions.
- Designing serial-to-parallel and parallel-to-serial data paths.
- Handling bidirectional open-drain communication signals.
- Developing and debugging RTL using simulation waveforms.

## Future Scope

- Integrate the individual blocks into a complete master-slave system.
- Develop a comprehensive top-level verification environment.
- Add support for repeated START conditions and multi-byte transactions.
- Verify timing compliance against the I²C Standard Mode specification.
- Explore synthesis and FPGA implementation.

---

**Project Domain:** Digital Design | RTL Design | Verilog | Serial Communication | FSM | FPGA

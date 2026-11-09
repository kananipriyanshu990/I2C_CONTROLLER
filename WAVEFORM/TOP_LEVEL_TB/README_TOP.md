# I2C_TOP UVM Testbench and Waveform Guide

This directory contains a UVM testbench for the current `I2C_TOP` RTL and a
guide for reading the ten waveform screenshots that document one complete
simulation run. The testbench exercises the integrated single-master,
single-local-slave setup. It sends twenty one-byte transactions: ten writes
and ten reads, alternating in that order.

## Testbench files

- `i2c_if.sv` defines the virtual interface and resolved I2C pins. `SDA` is a
  `tri1`, modeling the external pull-up used by the open-drain bus.
- `i2c_uvm_pkg.sv` contains the transaction, alternating sequence, driver,
  monitor, scoreboard, environment, and test.
- `tb_top.sv` creates the 100 MHz clock, applies active-low reset, connects
  `I2C_TOP`, and launches `i2c_top_test`.

The transaction and sequence objects are constructed directly with `new()`.
UVM component factory registration remains enabled so `run_test` can create
the test by name.

## What the test checks

For every transfer, the driver waits for `DONE` and reports a timeout if it is
not seen within 30,000 system-clock cycles. The monitor observes only
top-level signals and publishes one completed transaction. The scoreboard
checks that:

1. The addressed transfer completes without `ACK_ERROR`.
2. `DATA_VALID` is observed.
3. The returned `DATA_OUT` byte matches the transaction's `DATA_IN` byte.

For writes, the master sends `DATA_IN` and the local slave reports the
received byte. For reads, the local slave transmits `DATA_IN` and the master
reports the received byte. The test sequence randomizes the address and data
for each transaction while alternating write and read commands.

## How the ten screenshots fit together

The sequence begins with a write and alternates directions. Each screenshot
is one consecutive write/read pair in the same simulation, so the ten images
show transactions 1 through 20 in chronological order. Read each row from
left to right and then continue to the next row. The transaction numbers below
refer to sequence order; randomized addresses and data will differ between
runs.

| Screenshot | Transactions shown | First operation | Second operation |
|---|---:|---|---|
| `UVM_1.png` | 1–2 | Write 1 | Read 2 |
| `UVM_2.png` | 3–4 | Write 3 | Read 4 |
| `UVM_3.png` | 5–6 | Write 5 | Read 6 |
| `UVM_4.png` | 7–8 | Write 7 | Read 8 |
| `UVM_5.png` | 9–10 | Write 9 | Read 10 |
| `UVM_6.png` | 11–12 | Write 11 | Read 12 |
| `UVM_7.png` | 13–14 | Write 13 | Read 14 |
| `UVM_8.png` | 15–16 | Write 15 | Read 16 |
| `UVM_9.png` | 17–18 | Write 17 | Read 18 |
| `UVM_10.png` | 19–20 | Write 19 | Read 20 |

A screenshot is one portion of the waveform timeline; the full set documents the complete
twenty-transfer sequence.

## Signals to follow in each capture

- `START` begins the command. `READ=0` selects write; `READ=1` selects read.
- `SLAVE_ADDR` and `DATA_IN` are the command address and byte. The local slave
  uses the same address input and, for reads, sources its transmit byte from
  `DATA_IN`.
- `SCL` is the serial clock. `SDA` carries the address, direction bit, data,
  ACK/NACK, and START/STOP conditions.
- `MASTER_BUSY` and `SLAVE_BUSY` show the active transfer. `ACK_ERROR` should
  remain low for the matching local slave address.
- `DATA_VALID` marks a completed data byte and `DATA_OUT` is that byte.
- `DONE` marks completion of the master's one-byte transaction.

When reading adjacent captures, use the `DONE` pulse at the end of one
operation and the next `START` pulse as the boundary between transactions.
The screenshots should collectively show ten such write/read pairs, with no
missing transfer between numbered captures.



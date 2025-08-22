Arbiter PUF on Nexys A7
🔑 Introduction

A Physically Unclonable Function (PUF) is a hardware primitive that turns tiny, random manufacturing variations in silicon into a unique digital “fingerprint.” Unlike traditional secret keys that can be stored or copied, a PUF generates secrets on demand, making it attractive for hardware security, authentication, and anti-counterfeiting.

This project implements an Arbiter PUF on the Digilent Nexys A7 (Artix-7) FPGA. The design demonstrates how delay-based circuits can generate stable yet unique challenge-response pairs (CRPs), suitable for applications such as key generation and device identification.

🚀 Why Use a PUF?

Unclonable: No two chips — even from the same wafer — will produce the same responses.

Lightweight: Minimal hardware overhead compared to secure NVM or cryptographic accelerators.

On-demand: Keys are never permanently stored; they are created when needed.

🖥️ Project Overview

Board: Nexys A7-100T (Artix-7 FPGA)

Core RTL: Arbiter PUF with configurable number of stages

Interface: UART for challenge-response collection

Tooling: Python scripts for data capture + metrics evaluation

The Arbiter PUF is built from a chain of multiplexers. Two racing signals travel through slightly different paths, and an arbiter latch decides which one arrived first, producing a single response bit. Repeating this process with many challenges creates a CRP dataset unique to each device.

📂 Repository Layout
hw/         → Top module and XDC constraints
rtl/        → Arbiter PUF core + support logic (UART, LFSR)
sim/        → Testbenches and delay line simulation
scripts/    → Python for CRP collection + metric analysis
docs/       → (Add results, plots, or board photos here)

⚙️ Prerequisites

Vivado 2023.2 (or similar version)

Python 3.8+ with pyserial, numpy, matplotlib

🛠️ Build & Run
1. Synthesize in Vivado

Create project → add rtl/*.v and hw/top.v.

Apply constraints from hw/nexys_a7_example.xdc.

Set top.v as top module.

Run synthesis → implementation → bitstream.

Program the Nexys A7 board.

2. Collect Challenge-Response Pairs

Connect UART (115200 8N1) and run: **python3 scripts/collect_uart.py > chipA.csv
**
Repeat on another board (or after power cycling) to compare.
Evaluate Metrics p**ython3 scripts/puf_metrics.py chipA.csv chipB.csv
**
Outputs:

Uniqueness – differences across chips (~50% expected)

Reliability – stability across runs (>95% ideal)

Uniformity – balance of 0s/1s (~50% expected)
Uniqueness (A vs B):   0.493
Reliability (A):       0.961
Uniformity (A):        0.502

🔒 Applications

Device authentication

Secure key generation

Anti-counterfeiting tags

Lightweight cryptographic building blocks

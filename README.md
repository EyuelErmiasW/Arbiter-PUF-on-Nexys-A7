Arbiter PUF on Nexys A7
Introduction

Modern hardware systems need secure ways to generate and protect secrets. Traditional keys stored in memory can be cloned or extracted, but a Physically Unclonable Function (PUF) takes advantage of the unavoidable manufacturing variations in silicon to create a “fingerprint” unique to each chip.
This project implements an Arbiter PUF on a Xilinx Nexys A7 (Artix-7) FPGA. The goal is to demonstrate how a simple delay-based circuit can be used to produce unpredictable yet repeatable responses for cryptographic applications such as device authentication and key generation.

Why Use a PUF?

Unclonable – Even chips made from the same design have tiny variations in wire delay that cannot be copied.

Lightweight – PUFs require far less logic than storing and protecting keys in NVM.

On-demand secrets – Keys are generated when needed and do not need to be permanently stored.

Project Overview

FPGA Board: Digilent Nexys A7-100T (Artix-7)

Core RTL: Arbiter PUF with configurable number of stages

Interface: UART for challenge-response testing

Tooling: Python scripts for data collection and metric evaluation (uniqueness, reliability, uniformity)

The Arbiter PUF consists of a chain of multiplexers that race two signals through slightly different paths. An arbiter latch decides which signal arrived first, outputting a single response bit. Repeating this for many random “challenges” produces a challenge-response pair (CRP) dataset unique to each FPGA.

Prerequisites

Xilinx Vivado 2023.2 (or similar)

Python 3.8+ with pyserial, numpy, matplotlib

FPGA Build

Open Vivado → Create Project → Add sources (rtl/ and hw/top.v).

Add constraints (hw/nexys_a7_example.xdc).

Set top.v as top module.

Run synthesis → implementation → generate bitstream.

Program the Nexys A7 board.

Data Collection

Connect USB-UART (115200 8N1).

Run: python3 scripts/collect_uart.py > chipA.csv
Repeat on another board or after power cycling to compare results.

Metrics
python3 scripts/puf_metrics.py chipA.csv chipB.csv


Outputs:

Uniqueness (different chips differ ~50%)

Reliability (same chip stable across runs)

Uniformity (balance of 0s and 1s)

Uniqueness A vs B:   0.493
Reliability A:       0.961
Uniformity A:        0.502

Applications

Secure key generation

Hardware authentication

Anti-counterfeiting measures

Lightweight cryptographic primitives

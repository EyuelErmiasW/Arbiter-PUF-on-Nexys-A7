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

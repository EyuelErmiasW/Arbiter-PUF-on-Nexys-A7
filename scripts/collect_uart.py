# scripts/collect_uart.py
# Collect CRPs from the FPGA over UART.
# Expects lines like: C,<hex_challenge>,R,<bit>
# Usage: python3 collect_uart.py /dev/ttyUSB0 output.csv

import sys
import csv
import serial

def main():
    if len(sys.argv) < 3:
        print("Usage: python3 collect_uart.py <serial_port> <out.csv>")
        sys.exit(1)

    port = sys.argv[1]
    outp = sys.argv[2]

    ser = serial.Serial(port, baudrate=115200, timeout=2)
    print(f"Reading from {port} at 115200 baud")
    with open(outp, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["challenge", "response"])
        try:
            while True:
                line = ser.readline().decode(errors="ignore").strip()
                if not line:
                    continue
                # Expected format: C,<hex>,R,<bit>
                parts = line.split(",")
                if len(parts) == 4 and parts[0] == "C" and parts[2] == "R":
                    chal_hex = parts[1].strip()
                    bit = parts[3].strip()
                    if all(c in "0123456789abcdefABCDEF" for c in chal_hex) and bit in ("0", "1"):
                        w.writerow([chal_hex, bit])
                        print(f"{chal_hex},{bit}")
        except KeyboardInterrupt:
            print("Stopped.")

if __name__ == "__main__":
    main()

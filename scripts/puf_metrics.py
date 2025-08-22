# scripts/puf_metrics.py
# Usage: python3 puf_metrics.py chipA.csv chipB.csv
import sys
import csv

def load_bits(path):
    chals = []
    bits = []
    with open(path, newline='') as f:
        r = csv.DictReader(f)
        for row in r:
            chals.append(int(row['challenge'], 16))
            bits.append(int(row['response']))
    return chals, bits

def hamming(a, b):
    return sum(1 for x, y in zip(a, b) if x != y)

def mean(xs):
    return sum(xs) / float(len(xs)) if xs else 0.0

def main():
    if len(sys.argv) < 3:
        print("Usage: python3 puf_metrics.py chipA.csv chipB.csv")
        sys.exit(1)
    chA, bA = load_bits(sys.argv[1])
    chB, bB = load_bits(sys.argv[2])

    # Uniformity
    uniA = mean(bA)
    uniB = mean(bB)

    # Uniqueness for same challenges
    if chA != chB:
        print("Warning: challenge sets differ. Sorting by challenge.")
        zippedA = sorted(zip(chA, bA))
        zippedB = sorted(zip(chB, bB))
        bA = [b for _, b in zippedA]
        bB = [b for _, b in zippedB]

    uniqueAB = hamming(bA, bB) / float(len(bA))

    print(f"Uniformity A: {uniA:.3f}")
    print(f"Uniformity B: {uniB:.3f}")
    print(f"Uniqueness A vs B: {uniqueAB:.3f}")

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
import sys

# Default hardcoded paths
default_golden = "/home/abirfan/abirfan-pd4/verif/golden/rv32ui-p-add.trace"
default_sim = "/home/abirfan/abirfan-pd4/verif/sim/verilator/test_pd/rv32ui-p-add.trace"

# Use command line arguments if provided
if len(sys.argv) == 3:
    golden_path = sys.argv[1]
    sim_path = sys.argv[2]
else:
    golden_path = default_golden
    sim_path = default_sim

try:
    with open(golden_path, 'r') as f:
        golden_lines = f.readlines()
except FileNotFoundError:
    print(f"Error: Golden trace file not found at {golden_path}")
    sys.exit(1)

try:
    with open(sim_path, 'r') as f:
        sim_lines = f.readlines()
except FileNotFoundError:
    print(f"Error: Sim trace file not found at {sim_path}")
    sys.exit(1)

# Compare top 100 lines (or fewer if file has less than 100)
num_lines = min(100, len(golden_lines), len(sim_lines))
mismatches = 0

for i in range(num_lines):
    if golden_lines[i].strip() != sim_lines[i].strip():
        print(f"Mismatch at line {i+1}:")
        print(f"  Golden: {golden_lines[i].strip()}")
        print(f"  Sim   : {sim_lines[i].strip()}")
        mismatches += 1

if mismatches == 0:
    print(f"All top {num_lines} lines match!")
else:
    print(f"Total mismatches in top {num_lines} lines: {mismatches}")

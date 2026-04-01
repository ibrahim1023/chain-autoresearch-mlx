#!/usr/bin/env python3
import pathlib
import re
import statistics
import subprocess
import sys


SNAPSHOT_PATH = pathlib.Path(".gas-snapshot.current")
PATTERN = re.compile(r"GasBenchmarkTest:(testGas[^(]+\(\))\s+\((?:gas:\s*)?(\d+)\)")


def parse_snapshot(path: pathlib.Path) -> list[tuple[str, int]]:
    metrics: list[tuple[str, int]] = []
    for line in path.read_text().splitlines():
        match = PATTERN.search(line)
        if match:
            metrics.append((match.group(1), int(match.group(2))))
    return metrics


def main() -> int:
    cmd = [
        "forge",
        "snapshot",
        "--match-contract",
        "GasBenchmarkTest",
        "--snap",
        str(SNAPSHOT_PATH),
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode != 0:
        sys.stderr.write(proc.stdout)
        sys.stderr.write(proc.stderr)
        return proc.returncode

    metrics = parse_snapshot(SNAPSHOT_PATH)
    if not metrics:
        sys.stderr.write("No benchmark gas metrics found in snapshot output.\n")
        return 2

    gas_values = [value for _, value in metrics]
    median_gas = int(statistics.median(gas_values))

    print("---")
    for name, value in metrics:
        print(f"{name}: {value}")
    print(f"median_gas: {median_gas}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
import argparse
import pathlib
import re
import statistics
import subprocess
import sys
from dataclasses import dataclass


SNAPSHOT_PATTERN = re.compile(r"(?P<contract>\w+):(?P<test>testGas[^(]+\(\))\s+\((?:gas:\s*)?(?P<gas>\d+)\)")


@dataclass(frozen=True)
class ArenaConfig:
    benchmark_contract: str
    snapshot_cmd: list[str]
    metric_prefix: str
    target_name: str
    arena_name: str
    snapshot_path: pathlib.Path


@dataclass(frozen=True)
class GasMetric:
    contract: str
    test_name: str
    gas: int

    @property
    def case_name(self) -> str:
        return f"{self.contract}:{self.test_name}"


def resolve_arena_config(arena: str, target: str | None) -> ArenaConfig:
    if arena != "zk_verifier_pack":
        raise ValueError("zk_verifier_pack requires --arena zk_verifier_pack")
    if target is None:
        raise ValueError("zk_verifier_pack requires --target")
    if target != "BN254Groth16Verifier":
        raise ValueError("zk_verifier_pack currently supports only BN254Groth16Verifier")

    return ArenaConfig(
        benchmark_contract="ZKVerifierPackBenchmarkTest",
        snapshot_cmd=[
            "forge",
            "snapshot",
            "--offline",
            "--match-contract",
            "ZKVerifierPackBenchmarkTest",
            "--snap",
            ".gas-snapshot.zk_verifier_pack.current",
        ],
        metric_prefix="testGasBN254Groth16Verifier",
        target_name=target,
        arena_name="zk_verifier_pack",
        snapshot_path=pathlib.Path(".gas-snapshot.zk_verifier_pack.current"),
    )


def parse_snapshot_text(text: str) -> list[GasMetric]:
    metrics: list[GasMetric] = []
    for line in text.splitlines():
        match = SNAPSHOT_PATTERN.search(line)
        if not match:
            continue
        metrics.append(
            GasMetric(
                contract=match.group("contract"),
                test_name=match.group("test"),
                gas=int(match.group("gas")),
            )
        )
    return metrics


def select_metrics(metrics: list[GasMetric], benchmark_contract: str, metric_prefix: str) -> list[GasMetric]:
    return [
        metric
        for metric in metrics
        if metric.contract == benchmark_contract and metric.test_name.startswith(metric_prefix)
    ]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--arena", choices=["zk_verifier_pack"], default="zk_verifier_pack")
    parser.add_argument("--target", choices=["BN254Groth16Verifier"])
    args = parser.parse_args()

    try:
        config = resolve_arena_config(args.arena, args.target)
    except ValueError as exc:
        parser.error(str(exc))

    proc = subprocess.run(config.snapshot_cmd, capture_output=True, text=True)
    if proc.returncode != 0:
        sys.stderr.write(proc.stdout)
        sys.stderr.write(proc.stderr)
        return proc.returncode

    snapshot_text = proc.stdout
    if config.snapshot_path.exists():
        snapshot_text = f"{snapshot_text}\n{config.snapshot_path.read_text()}"

    metrics = select_metrics(parse_snapshot_text(snapshot_text), config.benchmark_contract, config.metric_prefix)
    if not metrics:
        sys.stderr.write("No benchmark gas metrics found in snapshot output.\n")
        return 2

    gas_values = [metric.gas for metric in metrics]
    median_gas = int(statistics.median(gas_values))
    worst_case = max(metrics, key=lambda metric: metric.gas)

    print("---")
    print(f"arena: {config.arena_name}")
    print(f"target: {config.target_name}")
    print(f"benchmark_contract: {config.benchmark_contract}")
    print(f"metric_count: {len(metrics)}")
    for metric in metrics:
        print(f"{metric.case_name}: {metric.gas}")
    print(f"median_gas: {median_gas}")
    print(f"worst_case_gas: {worst_case.gas}")
    print(f"worst_case_name: {worst_case.case_name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

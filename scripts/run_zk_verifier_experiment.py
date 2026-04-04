#!/usr/bin/env python3
import argparse
import pathlib
import re
import statistics
import subprocess
import sys
from dataclasses import dataclass


DEFAULT_RESULTS_PATH = pathlib.Path("results.zk_verifier_pack.tsv")
SNAPSHOT_PATTERN = re.compile(r"(?P<contract>\w+):(?P<test>testGas[^(]+\(\))\s+\((?:gas:\s*)?(?P<gas>\d+)\)")


@dataclass(frozen=True)
class ArenaConfig:
    arena: str
    target: str | None
    test_cmd: list[str]
    rejection_cmd: list[str]
    snapshot_cmd: list[str]
    benchmark_contract: str
    metric_prefix: str
    snapshot_path: pathlib.Path


@dataclass
class StepResult:
    name: str
    returncode: int
    stdout: str
    stderr: str
    timed_out: bool = False


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
        arena="zk_verifier_pack",
        target=target,
        test_cmd=["forge", "test", "--match-path", "test/zk_verifier_pack/BN254Groth16Verifier.t.sol"],
        rejection_cmd=["forge", "test", "--match-path", "test/zk_verifier_pack/BN254Groth16VerifierRejection.t.sol"],
        snapshot_cmd=[
            "forge",
            "snapshot",
            "--offline",
            "--match-contract",
            "ZKVerifierPackBenchmarkTest",
            "--snap",
            ".gas-snapshot.zk_verifier_pack.current",
        ],
        benchmark_contract="ZKVerifierPackBenchmarkTest",
        metric_prefix="testGasBN254Groth16Verifier",
        snapshot_path=pathlib.Path(".gas-snapshot.zk_verifier_pack.current"),
    )


def run_step(name: str, cmd: list[str], timeout_seconds: int) -> StepResult:
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout_seconds)
        return StepResult(
            name=name,
            returncode=proc.returncode,
            stdout=proc.stdout,
            stderr=proc.stderr,
        )
    except subprocess.TimeoutExpired as exc:
        return StepResult(
            name=name,
            returncode=124,
            stdout=exc.stdout or "",
            stderr=exc.stderr or "",
            timed_out=True,
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


def ensure_results_file(path: pathlib.Path) -> None:
    if path.exists():
        return
    path.write_text("commit\tmedian_gas\tstatus\tdescription\n")


def append_result(path: pathlib.Path, commit: str, median_gas: int, status: str, description: str) -> None:
    ensure_results_file(path)
    with path.open("a", encoding="utf-8") as handle:
        handle.write(f"{commit}\t{median_gas}\t{status}\t{description}\n")


def git_short_commit() -> str:
    proc = subprocess.run(
        ["git", "rev-parse", "--short", "HEAD"],
        capture_output=True,
        text=True,
        check=False,
    )
    if proc.returncode != 0:
        return "unknown"
    return proc.stdout.strip() or "unknown"


def print_step_output(step: StepResult) -> None:
    if step.stdout:
        sys.stdout.write(step.stdout)
    if step.stderr:
        sys.stderr.write(step.stderr)


def print_success(config: ArenaConfig, metrics: list[GasMetric]) -> None:
    gas_values = [metric.gas for metric in metrics]
    median_gas = int(statistics.median(gas_values))
    worst_case = max(metrics, key=lambda metric: metric.gas)

    print("---")
    print("status: ok")
    print(f"arena: {config.arena}")
    print(f"target: {config.target or 'BN254Groth16Verifier'}")
    print(f"benchmark_contract: {config.benchmark_contract}")
    print(f"metric_count: {len(metrics)}")
    for metric in metrics:
        print(f"{metric.case_name}: {metric.gas}")
    print(f"median_gas: {median_gas}")
    print(f"worst_case_gas: {worst_case.gas}")
    print(f"worst_case_name: {worst_case.case_name}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--arena", choices=["zk_verifier_pack"], default="zk_verifier_pack")
    parser.add_argument("--target", choices=["BN254Groth16Verifier"])
    parser.add_argument("--test-timeout-seconds", type=int, default=60)
    parser.add_argument("--benchmark-timeout-seconds", type=int, default=60)
    parser.add_argument("--append-results", action="store_true")
    parser.add_argument("--results-path")
    parser.add_argument("--status", choices=["keep", "discard", "crash"])
    parser.add_argument("--description")
    args = parser.parse_args()

    if args.append_results and (args.status is None or args.description is None):
        parser.error("--append-results requires both --status and --description")

    try:
        config = resolve_arena_config(args.arena, args.target)
    except ValueError as exc:
        parser.error(str(exc))

    commit = git_short_commit()
    results_path = pathlib.Path(args.results_path) if args.results_path else DEFAULT_RESULTS_PATH

    test_step = run_step("forge_test", config.test_cmd, args.test_timeout_seconds)
    if test_step.returncode != 0:
        print_step_output(test_step)
        print("---")
        print("status: crash")
        print(f"arena: {config.arena}")
        print(f"target: {config.target or 'BN254Groth16Verifier'}")
        print("reason: test_timeout" if test_step.timed_out else "reason: test_failure")
        if args.append_results:
            append_result(results_path, commit, 0, "crash", args.description)
        return test_step.returncode

    rejection_step = run_step("forge_rejection", config.rejection_cmd, args.test_timeout_seconds)
    if rejection_step.returncode != 0:
        print_step_output(rejection_step)
        print("---")
        print("status: crash")
        print(f"arena: {config.arena}")
        print(f"target: {config.target or 'BN254Groth16Verifier'}")
        print("reason: rejection_timeout" if rejection_step.timed_out else "reason: rejection_failure")
        if args.append_results:
            append_result(results_path, commit, 0, "crash", args.description)
        return rejection_step.returncode

    benchmark_step = run_step("zk_benchmark", config.snapshot_cmd, args.benchmark_timeout_seconds)
    if benchmark_step.returncode != 0:
        print_step_output(benchmark_step)
        print("---")
        print("status: crash")
        print(f"arena: {config.arena}")
        print(f"target: {config.target or 'BN254Groth16Verifier'}")
        print("reason: benchmark_timeout" if benchmark_step.timed_out else "reason: benchmark_failure")
        if args.append_results:
            append_result(results_path, commit, 0, "crash", args.description)
        return benchmark_step.returncode

    snapshot_text = benchmark_step.stdout
    if config.snapshot_path.exists():
        snapshot_text = f"{snapshot_text}\n{config.snapshot_path.read_text()}"

    metrics = select_metrics(parse_snapshot_text(snapshot_text), config.benchmark_contract, config.metric_prefix)
    if not metrics:
        print("---")
        print("status: crash")
        print(f"arena: {config.arena}")
        print(f"target: {config.target or 'BN254Groth16Verifier'}")
        print("reason: missing_metric")
        if args.append_results:
            append_result(results_path, commit, 0, "crash", args.description)
        return 2

    print_success(config, metrics)

    if args.append_results:
        median_gas = int(statistics.median(metric.gas for metric in metrics))
        append_result(results_path, commit, median_gas, args.status, args.description)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

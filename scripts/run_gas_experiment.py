#!/usr/bin/env python3
import argparse
import pathlib
import re
import statistics
import subprocess
import sys
from dataclasses import dataclass


DEFAULT_RESULTS_BY_ARENA = {
    "v1": pathlib.Path("results.gas.tsv"),
    "gas_pack": pathlib.Path("results.gas_pack.tsv"),
}
SNAPSHOT_PATTERN = re.compile(r"(?P<contract>\w+):(?P<test>testGas[^(]+\(\))\s+\((?:gas:\s*)?(?P<gas>\d+)\)")


@dataclass(frozen=True)
class ArenaConfig:
    arena: str
    target: str | None
    test_cmd: list[str]
    invariant_cmd: list[str] | None
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
    if arena == "v1":
        if target is not None:
            raise ValueError("v1 does not accept --target")
        return ArenaConfig(
            arena="v1",
            target=None,
            test_cmd=["forge", "test", "--match-contract", "GasCandidateTest"],
            invariant_cmd=None,
            snapshot_cmd=[
                "forge",
                "snapshot",
                "--offline",
                "--match-contract",
                "GasBenchmarkTest",
                "--snap",
                ".gas-snapshot.v1.current",
            ],
            benchmark_contract="GasBenchmarkTest",
            metric_prefix="testGas",
            snapshot_path=pathlib.Path(".gas-snapshot.v1.current"),
        )

    if target is None:
        raise ValueError("gas_pack requires --target")

    target_to_test_path = {
        "TokenLedger": "test/gas_pack/TokenLedger.t.sol",
        "RewardDistributor": "test/gas_pack/RewardDistributor.t.sol",
        "MerkleClaimer": "test/gas_pack/MerkleClaimer.t.sol",
    }
    if target not in target_to_test_path:
        valid_targets = ", ".join(sorted(target_to_test_path))
        raise ValueError(f"unsupported gas_pack target '{target}', expected one of: {valid_targets}")

    return ArenaConfig(
        arena="gas_pack",
        target=target,
        test_cmd=["forge", "test", "--match-path", target_to_test_path[target]],
        invariant_cmd=(
            ["forge", "test", "--match-path", "test/gas_pack/TokenLedgerInvariant.t.sol"]
            if target == "TokenLedger"
            else None
        ),
        snapshot_cmd=[
            "forge",
            "snapshot",
            "--offline",
            "--match-contract",
            "GasPackBenchmarkTest",
            "--snap",
            ".gas-snapshot.gas_pack.current",
        ],
        benchmark_contract="GasPackBenchmarkTest",
        metric_prefix=f"testGas{target}",
        snapshot_path=pathlib.Path(".gas-snapshot.gas_pack.current"),
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


def select_metrics(metrics: list[GasMetric], config: ArenaConfig) -> list[GasMetric]:
    return [
        metric
        for metric in metrics
        if metric.contract == config.benchmark_contract and metric.test_name.startswith(config.metric_prefix)
    ]


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


def ensure_results_file(path: pathlib.Path) -> None:
    if path.exists():
        return
    path.write_text("commit\tmedian_gas\tstatus\tdescription\n")


def append_result(path: pathlib.Path, commit: str, median_gas: int, status: str, description: str) -> None:
    ensure_results_file(path)
    with path.open("a", encoding="utf-8") as handle:
        handle.write(f"{commit}\t{median_gas}\t{status}\t{description}\n")


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
    print(f"target: {config.target or 'GasCandidate'}")
    print(f"benchmark_contract: {config.benchmark_contract}")
    print(f"metric_count: {len(metrics)}")
    for metric in metrics:
        print(f"{metric.case_name}: {metric.gas}")
    print(f"median_gas: {median_gas}")
    print(f"worst_case_gas: {worst_case.gas}")
    print(f"worst_case_name: {worst_case.case_name}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--arena", choices=["v1", "gas_pack"], default="v1")
    parser.add_argument("--target", choices=["TokenLedger", "RewardDistributor", "MerkleClaimer"])
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
    results_path = pathlib.Path(args.results_path) if args.results_path else DEFAULT_RESULTS_BY_ARENA[config.arena]

    test_step = run_step("forge_test", config.test_cmd, args.test_timeout_seconds)
    if test_step.returncode != 0:
        print_step_output(test_step)
        print("---")
        print("status: crash")
        print(f"arena: {config.arena}")
        print(f"target: {config.target or 'GasCandidate'}")
        print("reason: test_timeout" if test_step.timed_out else "reason: test_failure")
        if args.append_results:
            append_result(results_path, commit, 0, "crash", args.description)
        return test_step.returncode

    if config.invariant_cmd is not None:
        invariant_step = run_step("forge_invariant", config.invariant_cmd, args.test_timeout_seconds)
        if invariant_step.returncode != 0:
            print_step_output(invariant_step)
            print("---")
            print("status: crash")
            print(f"arena: {config.arena}")
            print(f"target: {config.target or 'GasCandidate'}")
            print("reason: invariant_timeout" if invariant_step.timed_out else "reason: invariant_failure")
            if args.append_results:
                append_result(results_path, commit, 0, "crash", args.description)
            return invariant_step.returncode

    benchmark_step = run_step("gas_benchmark", config.snapshot_cmd, args.benchmark_timeout_seconds)
    if benchmark_step.returncode != 0:
        print_step_output(benchmark_step)
        print("---")
        print("status: crash")
        print(f"arena: {config.arena}")
        print(f"target: {config.target or 'GasCandidate'}")
        print("reason: benchmark_timeout" if benchmark_step.timed_out else "reason: benchmark_failure")
        if args.append_results:
            append_result(results_path, commit, 0, "crash", args.description)
        return benchmark_step.returncode

    snapshot_text = benchmark_step.stdout
    if config.snapshot_path.exists():
        snapshot_text = f"{snapshot_text}\n{config.snapshot_path.read_text()}"

    metrics = select_metrics(parse_snapshot_text(snapshot_text), config)
    if not metrics:
        print("---")
        print("status: crash")
        print(f"arena: {config.arena}")
        print(f"target: {config.target or 'GasCandidate'}")
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

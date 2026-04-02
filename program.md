# chain-autoresearch

This file defines the operating procedure for the active blockchain research direction.

## Current State

The repository currently has:

- a completed V1 local gas-optimization arena
- an active V2 direction centered on a realistic `gas_pack` arena

V1 remains the only fully implemented arena today.

V2 is the active build target.

## V1 Reference Arena

The current implemented arena is:

- local smart contract gas optimization

The V1 editable target is:

- `contracts/GasCandidate.sol`

The V1 primary metric is:

- `median_gas`

The V1 validation command is:

```bash
python scripts/run_gas_experiment.py
```

That command currently:

- runs `forge test`
- runs the gas benchmark snapshot
- extracts per-case gas from `GasBenchmarkTest`
- reports `status: ok` only when tests pass and `median_gas` is present

Treat V1 as baseline history while V2 is being introduced.

## V2 Direction

The active next arena is:

- `gas_pack`

The intended V2 properties are:

- a small pack of realistic contracts
- one editable contract per search pass
- fixed benchmark fixtures and call sets
- stronger correctness checks
- invariant checks where practical
- one primary metric anchored to gas

Recommended initial contracts:

- `TokenLedger`
- `RewardDistributor`
- `MerkleClaimer`

## Core Rule

Keep the loop narrow:

1. choose one arena and one target
2. modify only that target during the pass
3. run the fixed validation and benchmark path
4. read one primary metric
5. log `keep`, `discard`, or `crash`
6. preserve deterministic comparison against the current kept baseline

Do not widen the editable surface unless the human explicitly changes scope.

## Fixed Surface

During normal experiments, keep these fixed for the chosen arena:

- benchmark fixtures
- benchmark scenarios
- correctness tests
- invariant checks
- metric extraction logic
- toolchain configuration
- runner scripts

For the current V1 arena, that fixed surface includes:

- `test/GasCandidate.t.sol`
- `test/GasBenchmark.t.sol`
- `scripts/run_gas_benchmark.py`
- `scripts/run_gas_experiment.py`
- `foundry.toml`

## Validation Standard

A run counts as valid only if:

- compilation succeeds
- correctness tests pass
- invariant checks pass when defined
- the benchmark completes
- the primary metric is present

Do not accept optimization claims that weaken correctness.

## Results Logging

V1 results are currently stored in:

- `results.gas.tsv`

Current V1 columns:

```text
commit	median_gas	status	description
```

Statuses:

- `keep`
- `discard`
- `crash`

Use `0` for `median_gas` on crashes.

When V2 begins producing real baselines, keep V2 results in a V2-specific log rather than mixing them into V1 history.

## Keep Or Discard Rule

Lower primary metric is better.

Keep a candidate when:

- validation passes
- the primary metric is present
- the primary metric improves meaningfully
- the code does not become unjustifiably more complex

Discard a candidate when:

- the metric is flat and the code is not simpler
- the metric is worse
- the change adds complexity without enough payoff

Crash a candidate when:

- tests fail
- invariants fail
- the benchmark fails
- the metric is missing
- the run times out

## Practical Rules

- Compare only against the current kept local baseline for the chosen target.
- Keep execution deterministic and offline.
- Prefer simple, interpretable changes.
- Preserve V1 command behavior while V2 is being introduced.
- Keep the runner simpler than the arena it orchestrates.
- Avoid broad framework rewrites when a narrow harness extension is enough.
- Do not treat V2 as complete before there is a real baseline.
- Keep one editable target per search pass.
- Do not mix gas, security, protocol, or strategy research in the same V2 loop.
- Do not widen the normal V2 path into a multi-file optimization framework.

## Current Best

At the time this file was last aligned:

- V1 best kept commit: `e3160d8`
- V1 best `median_gas`: `1502102`

That is a useful reference point, not the final project claim.

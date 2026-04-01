# AGENTS.md

## Project

**Name:** chain-autoresearch
**Type:** Deterministic local blockchain autoresearch repository
**Primary direction:** Realistic smart-contract gas optimization under strong correctness constraints
**Current state:** V1 exists as a completed narrow gas arena. The active next step is building the V2 `gas_pack` arena.

---

## Purpose

This repository defines a narrow blockchain autoresearch harness inspired by autoresearch.

The intended long-term shape remains:

- one fixed arena
- one editable target at a time
- one primary metric
- repeated keep-or-discard experiments

The active goal is no longer proving that a toy benchmark can run. V1 already did that.

The active goal now is:

- build a more meaningful deterministic local blockchain arena where gas wins on realistic contract patterns are credible and reproducible

Implementation must preserve determinism, comparability, and narrow experimental scope.

---

## How To Work Here

- Prefer small, scoped changes.
- Complete one concrete task at a time unless tasks are tightly coupled.
- Read `context.md` first if it exists and anchor decisions to it.
- Read `scope.md`, `task.md`, `program.md`, and `README.md` before making structural decisions.
- Treat `scope.md` as the source of truth when documents conflict.
- Treat `task.md` as the active execution checklist.
- Update `task.md` as work is completed.
- Tick completed tasks in `task.md` immediately (`[ ]` -> `[x]`).
- Update `README.md` when the user-facing project description changes.
- Keep V2 narrow and deterministic.
- Preserve V1 as baseline history while V2 is being introduced.
- Do not overwrite unrelated user changes.
- Use ASCII unless a file already requires something else.
- Keep logic explicit and testable.
- Prefer simple, interpretable harnesses over broad frameworks.
- After substantial work, provide a suggested commit message.

---

## Repository Anchors

- `AGENTS.md`: contributor operating rules
- `context.md`: current state anchor when present
- `scope.md`: project boundary and source of truth
- `task.md`: active checklist and execution tracker
- `program.md`: operating procedure for the active blockchain arena
- `README.md`: human-facing project description

Current active blockchain files:

- `contracts/GasCandidate.sol`
- `test/GasCandidate.t.sol`
- `test/GasBenchmark.t.sol`
- `scripts/run_gas_benchmark.py`
- `scripts/run_gas_experiment.py`
- `results.gas.tsv`

Legacy MLX-era files still present:

- `prepare.py`
- `train.py`
- `results.tsv`

Those legacy files remain part of repo history, not the active blockchain benchmark contract.

---

## Core Design Principles

- Deterministic local execution
- One editable target per search pass
- One primary metric per arena
- Strong correctness gates
- Explicit keep-or-discard decisions
- Reproducible experiment history
- Interpretable harness design
- Narrow scope before broader ambition

---

## Current Working Model

V1 is already implemented in narrow form:

- one editable contract target
- one fixed benchmark contract
- one primary gas metric
- one keep-or-discard loop

V1 proves the method works locally.

It does not yet prove the repo is doing meaningful blockchain research.

The active recommended V2 is:

- `gas_pack`

That implies:

- a small pack of realistic contracts
- one editable contract per search pass
- fixed benchmark fixtures
- fixed correctness tests
- invariant checks where practical
- one primary metric, expected to remain median gas

---

## Preferred Repo Direction

Prefer this sequence:

1. align project docs and operating rules with V2 reality
2. preserve V1 as reference history
3. define the V2 `gas_pack` layout
4. scaffold the first realistic contracts
5. extend the runner for selected-contract V2 execution
6. establish the first valid V2 baseline
7. only then begin V2 optimization loops

Do not skip directly to optimization before the V2 arena is real.

---

## Editable Surface

Right now, the editable surface includes coordination files and the blockchain harness itself.

Coordination files:

- `scope.md`
- `task.md`
- `AGENTS.md`
- `program.md`
- `README.md`
- `context.md`

Current V1 arena files:

- `contracts/GasCandidate.sol`
- `test/GasCandidate.t.sol`
- `test/GasBenchmark.t.sol`
- `scripts/run_gas_benchmark.py`
- `scripts/run_gas_experiment.py`

During a normal V2 search pass, the editable surface should collapse to one chosen target file inside the V2 pack.

---

## Validation Rules

For a blockchain optimization result to count as valid:

- compilation must succeed
- correctness tests must pass
- invariant checks must pass when defined
- the benchmark must complete
- the primary metric must be present

Do not accept gas wins that come from weakening correctness.

---

## Decision Criteria

Prefer work that:

- makes the V2 arena more concrete
- narrows ambiguity
- improves determinism and comparability
- strengthens correctness validation
- keeps the harness understandable
- preserves a clean separation between V1 history and V2 work

Prefer one honest, narrow, working arena over a broad but vague architecture.

---

## Non-Goals For Current Work

Unless the human explicitly expands scope, do not treat these as current goals:

- continuing MLX benchmark tuning
- treating legacy MLX files as active benchmark files
- turning the repo into a generic multi-chain platform
- supporting live on-chain execution
- mixing many editable files into one experiment loop
- combining gas, security, strategy, and protocol research into one arena
- optimizing multiple primary metrics at once

---

## Practical Rules

- Be explicit about what is implemented versus directional.
- If `program.md` conflicts with `scope.md`, follow `scope.md`.
- If a file is stale but not yet rewritten, say so clearly in `task.md`.
- Keep benchmark logic fixed during normal optimization passes.
- Avoid broad rewrites when a narrow scaffold or harness change is enough.
- Do not silently treat V1 as V2.
- Do not silently treat legacy MLX files as part of the blockchain contract.

---

## Core Principle

Make the blockchain work concrete by staying narrow:

- one arena
- one editable target at a time
- one primary metric
- deterministic local execution

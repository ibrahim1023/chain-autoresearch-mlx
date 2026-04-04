# Blockchain Scope

## Purpose

This repository is now a blockchain autoresearch project.

Its purpose is to build deterministic local research arenas where an agent can repeatedly:

1. modify one target
2. run a fixed benchmark
3. measure one primary metric
4. keep or discard the result

The project is no longer just "do something with blockchain." The direction is now:

- use the autoresearch loop to optimize or discover something meaningful in blockchain systems

## Current State

V1 already exists in basic form:

- one local gas-optimization arena
- one editable contract target
- one gas metric
- one keep-or-discard loop

That proves the method works at a small scale.

It does **not** yet prove that the repo is doing important blockchain research.

## V2 Goal

V2 should move the project from a toy gas benchmark to a meaningful blockchain research harness.

The recommended V2 objective is:

- optimize realistic smart-contract implementations for gas while preserving stronger correctness guarantees

That means V2 should focus on:

- more realistic contracts
- broader benchmark coverage
- stronger invariant or correctness gates
- structured experiment output

## Core V2 Direction

The best next step is a **Gas Pack V2** arena rather than a broader platform rewrite.

Gas Pack V2 should contain multiple realistic contract patterns such as:

- token bookkeeping
- reward distribution
- Merkle claim logic
- vault-style accounting
- role or allowlist management

The goal is to make optimization wins more credible than they are on a single toy contract.

## V2 Research Standard

For V2 to count as meaningful, the repo should show that the loop can:

- produce gas improvements on realistic contract patterns
- preserve correctness under stronger checks than simple happy-path tests
- outperform obvious manual baselines on a fixed local benchmark

That is a stronger claim than "we reduced gas on one sample contract."

## Meaningful Result Bar

The repo should distinguish clearly between:

### Working V2 Infrastructure

This means the repo can:

- run a realistic local contract benchmark
- optimize one selected target at a time
- record append-only keep-or-discard history
- enforce correctness tests
- enforce invariant-style validation for at least one target

This is necessary progress, but it is not yet a strong blockchain research result.

### Meaningful V2 Result

For a V2 result to count as meaningful, the repo should show all of the following:

- a real gas improvement on at least one realistic contract pattern
- invariant-preserving correctness on that target
- a benchmark and validation setup that remains fixed during the search pass
- a win that beats an obvious manual baseline, not just an earlier naive draft
- enough contract coverage that the repo is not relying on a single cherry-picked example

Until that standard is met, the repo should describe its state as:

- working V2 infrastructure with early promising results

not:

- a proven autonomous blockchain research system

## Current Claim Boundary

At the current repository state, the strongest honest claim is:

- the repo has a working V2 gas-pack harness
- it has completed search passes on all three initial gas-pack contracts
- it has kept gas wins on `TokenLedger`, `RewardDistributor`, and `MerkleClaimer` under stronger validation paths than V1
- all three current gas-pack contracts now also beat their frozen stronger manual comparators

The repo should not yet claim:

- superiority over stronger manual comparators outside the current fixed pack
- a generally reliable autonomous blockchain optimizer

The next work needed for a stronger claim is:

- expand the pack to one additional realistic contract pattern with the same fixed validation and benchmark discipline
- the chosen next pattern is a narrow vault-style accounting target named `VaultAccounting`
- establish a real baseline and search pass on that fourth target before making stronger breadth claims
- show that the wins remain credible against a stronger comparison bar across the whole pack

## Manual Baseline Policy

For the current gas-pack phase, an "obvious manual baseline" means:

- the first validated, readability-first implementation kept for a given contract
- measured under the same fixed benchmark and validation surface as later optimized candidates
- treated as the manual reference point unless and until the repo defines a stronger external manual comparator

This is a practical repository baseline policy, not a claim that the baseline is a globally expert implementation.

Current manual baselines are:

- `TokenLedger`: commit `5520615`, `median_gas = 835526`
- `RewardDistributor`: commit `ffa7fae`, `median_gas = 887232`
- `MerkleClaimer`: commit `11f5a1f`, `median_gas = 250228`

## Stronger Manual Comparator Policy

The next comparison bar should be stricter than the repository baseline policy.

A stronger manual comparator means:

- a plausible careful human gas-aware implementation
- still readable and maintainable
- still constrained by the same fixed benchmark and validation surface
- chosen explicitly before claiming that the loop beat it

Current stronger comparator styles are:

- `TokenLedger`
  - comparator style: a careful human implementation that specializes common mint and transfer paths, minimizes repeated reads, and avoids unnecessary storage writes while preserving simple accounting
- `RewardDistributor`
  - comparator style: a careful human implementation that optimizes the zero-accrual setup path, avoids redundant debt updates, and treats claim-path accounting as the main gas hotspot
- `MerkleClaimer`
  - comparator style: a careful human implementation that treats proof verification and claim-state writes as the main hotspot, and uses simple but gas-aware proof traversal without sacrificing correctness clarity

These stronger comparators differ from the repository baseline policy because they assume:

- intentional gas-aware design choices from the start
- hotspot-aware structure rather than merely readability-first code
- explicit comparison against a more competent manual implementation style

The repo now has direct evidence against those stronger comparators through frozen sibling implementations and a separate fixed comparator benchmark suite.

## Cross-Contract Evidence

Current fixed-pack evidence looks like this:

- `TokenLedger`
  - best kept result: `813699`
  - baseline: `835526`
  - outcome: beat the current manual baseline
  - stronger comparator: `831827`
  - stronger-comparator outcome: beat stronger comparator
- `RewardDistributor`
  - best kept result: `862368`
  - baseline: `887232`
  - outcome: beat the current manual baseline
  - stronger comparator: `894867`
  - stronger-comparator outcome: beat stronger comparator
- `MerkleClaimer`
  - best kept result: `236051`
  - baseline: `250228`
  - outcome: beat the current manual baseline
  - stronger comparator: `236456`
  - stronger-comparator outcome: beat stronger comparator

This means the repo now has:

- multi-contract validation coverage across the initial gas-pack
- multi-contract baseline coverage across the initial gas-pack
- three contracts with kept gas wins
- three of three current targets beating frozen stronger manual comparators

That is enough to support a narrower claim of broad success across the current initial gas-pack contract patterns.

It is also enough to support a narrower claim of success against the frozen stronger manual comparators for the current fixed pack.

It is still not enough to support a stronger claim of superiority over broader external manual comparators or of a generally reliable autonomous blockchain optimizer.

## Arena Model

The repo should still preserve the same core autoresearch model:

- one fixed arena
- one editable target at a time
- one primary metric
- deterministic local execution
- append-only experiment history

Even if V2 includes a contract pack, each experiment should still modify only one chosen target at a time.

## Narrow Arena Discipline

V2 should remain intentionally narrow.

That means:

- one editable target per search pass
- one research mode at a time
- one local deterministic execution path
- one primary metric driving keep-or-discard decisions

The repo should avoid turning `gas_pack` into a generic framework too early.

In particular, V2 should not:

- mix gas optimization with protocol simulation in the same loop
- mix security research and gas optimization in the same loop
- widen a normal experiment pass to multiple editable files
- depend on live network state or remote execution

The reason for this restriction is not aesthetics. It is comparability.

A narrower arena is easier to validate, easier to interpret, and easier to reuse when later V3 arenas are added.

## Primary V2 Arena

The recommended primary V2 arena is:

- realistic gas optimization with invariant-preserving validation

### Editable Surface

During a normal search pass, one editable target should be selected, for example:

- `contracts/gas_pack/TokenLedger.sol`
- `contracts/gas_pack/RewardDistributor.sol`
- `contracts/gas_pack/MerkleClaimer.sol`
- `contracts/gas_pack/VaultAccounting.sol`

### Next Target Definition

The next gas-pack expansion target is:

- `VaultAccounting`

It should remain intentionally narrow:

- share-based vault accounting only
- no strategy integration
- no allowances or transfer layer
- no fee logic
- no rebasing behavior

The fixed accounting shape should be:

- `deposit(address account, uint256 assets)`
- `withdraw(address account, uint256 assets)`
- `redeem(address account, uint256 shares)`
- one explicit exchange-rate movement path such as `donate(uint256 assets)`

The benchmark should stay focused on common accounting hot spots:

- bootstrap deposit into an empty vault
- deposit after exchange-rate movement
- partial withdraw against an existing position
- full redeem of a position after exchange-rate movement

### Fixed Surface

The following should remain fixed during normal experiments:

- benchmark fixtures
- benchmark call sets
- correctness tests
- invariant checks
- metric extraction logic
- toolchain configuration
- runner scripts

### Primary Metric

The primary metric should remain simple and comparable, for example:

- median gas across a fixed benchmark suite

Possible secondary outputs:

- per-case gas
- worst-case gas
- bytecode size

But the keep-or-discard rule should still be anchored to one primary metric.

## Validation Standard

V2 should require stronger validation than V1.

A run should count as valid only if:

- compilation succeeds
- correctness tests pass
- invariant checks pass when defined
- the benchmark completes
- the primary metric is present

This is how the repo moves from micro-optimization toward credible blockchain research.

## Non-Goals For V2

V2 should not try to do all blockchain research at once.

Still out of scope for the immediate next step:

- live trading
- mainnet interaction
- wallet automation
- general multi-chain support
- protocol research, security research, and strategy research all at once
- many editable files in one experiment loop

The correct move is to strengthen one arena first.

## Future V3 Candidates

Only after Gas Pack V2 is solid should the repo expand into a second serious arena such as:

### Security / Invariant Discovery

- target: exploit harness, invariant harness, or transaction-sequence generator
- metric: reproduced failures, successful invariant breaks, or minimized exploit trace length

### Protocol Parameter Search

- target: one simulator config or parameter file
- metric: throughput, fairness, liquidation count, or similar

### ZK Verifier Research

- target: one verifier contract or verifier helper file
- metric: median gas across a fixed local verification benchmark suite
- validation: valid proofs verify, invalid proofs fail, and fixtures stay frozen during the pass

### Replay-Based Strategy Research

- target: one strategy file
- metric: profit net of costs on a fixed replay

These are valid future directions, but not the immediate V2 requirement.

The strongest current ZK candidate is:

- a narrow `zk_verifier_pack` arena

That future arena should stay narrow:

- one proof system only at first
- one verifier family only at first
- one editable target per pass
- one primary metric
- fixed valid and invalid proof fixtures
- no remote prover dependencies

The current recommended first ZK choice is:

- optimize verifier gas first, not proving time or constraint count

## Relationship To Existing Files

The repository still contains legacy MLX-era material.

Those files are part of repo history, but they are not the blockchain benchmark contract.

The active blockchain direction should be defined by:

- `scope.md`
- `task.md`
- `program.md`
- the blockchain arena files

## Decision

The V2 project definition is:

- build a deterministic local blockchain research harness that can autonomously optimize realistic smart-contract implementations for gas under strong correctness constraints

The most important next move is not broader scope. It is a better arena.

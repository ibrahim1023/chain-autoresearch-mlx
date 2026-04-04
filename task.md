# blockchain-autoresearch - V2 Task List

This file is the active checklist for moving the repository from the completed V1 toy gas arena into the V2 direction defined in `scope.md`.

V2 is not "more experiments on the same toy contract." V2 is about building a more meaningful blockchain research arena.

It is intended to be reused across sessions. Mark items `[x]` only when they are true for the current repository state.

## 0. V2 Alignment

- [x] `scope.md` defines the V2 direction instead of only the original V1 gas arena.
- [x] `AGENTS.md` is aligned with the V2 scope.
- [x] `task.md` reflects the V2 scope.
- [x] `program.md` is aligned with the V2 workflow rather than only the V1 single-contract loop.
- [x] `README.md` is aligned with the V2 direction rather than only the V1 toy arena.

Current Phase 0 notes:

- V1 proved the method works on a narrow local gas benchmark
- V2 now aims at realistic contract patterns with stronger correctness guarantees

## 1. Preserve V1 As Baseline History

- [x] Keep the V1 gas arena intact as a reference implementation.
- [x] Avoid breaking the existing V1 commands while V2 is being introduced.
- [x] Clearly separate V1 artifacts from the new V2 arena files.
- [x] Decide whether V1 should live under a `v1/` or `legacy/` path later, without blocking V2 now.

Current V1 reference state:

- V1 editable target: `contracts/GasCandidate.sol`
- V1 best commit: `e3160d8`
- V1 best `median_gas`: `1502102`
- V1 results log: `results.gas.tsv`

## 2. Define Gas Pack V2

- [x] Confirm the V2 arena name and directory layout.
- [x] Confirm the initial contract pack for V2.
- [x] Keep the V2 pack small enough to stay interpretable.
- [x] Define one primary V2 objective.
- [x] Define whether V2 experiments target one contract at a time inside the pack.

Recommended default:

- arena name: `gas_pack`
- one editable contract per search pass
- primary objective: minimize median gas for the chosen contract benchmark while preserving stronger correctness guarantees
- directory layout:
  - `contracts/gas_pack/`
  - `test/gas_pack/`

Current V2 pack decision:

- initial contracts: `TokenLedger`, `RewardDistributor`, `MerkleClaimer`
- V1 stays in place for now
- any later V1 relocation is deferred until after the first real V2 baseline exists

## 3. Choose The Initial V2 Contracts

- [x] Add a realistic token-bookkeeping contract.
- [x] Add a realistic reward-distribution contract.
- [x] Add a realistic Merkle-claim contract.
- [x] Decide whether to include a vault-style accounting contract in the first pack or defer it.
- [x] Keep the initial contract count small enough that the benchmark pack stays maintainable.

The point is not coverage for its own sake. The point is a contract set where gas wins mean more than they did in V1.

Current decision:

- defer vault-style accounting until after the first V2 benchmark path is working

## 4. Define The V2 Benchmark Contract

- [x] Define the fixed benchmark scenarios for each V2 contract.
- [x] Define stronger correctness tests for each V2 contract.
- [x] Add invariant checks where practical.
- [x] Define the primary metric aggregation rule across benchmark calls.
- [x] Decide whether V2 should also report per-case gas, worst-case gas, and bytecode size as secondary outputs.
- [x] Keep the keep-or-discard rule anchored to one primary metric.

Suggested default:

- primary metric: median gas across the fixed benchmark suite for the selected contract
- secondary outputs: per-case gas and worst-case gas

Current V2 benchmark definition:

- benchmark contract: `test/gas_pack/GasPackBenchmark.t.sol`
- `TokenLedger` fixed cases:
  - `testGasTokenLedgerMintBatch32`
  - `testGasTokenLedgerTransferFanout8`
- `RewardDistributor` fixed cases:
  - `testGasRewardDistributorSetShares16`
  - `testGasRewardDistributorClaimAfterDeposit16`
- `MerkleClaimer` fixed case:
  - `testGasMerkleClaimerClaimDepth3`
- primary aggregation rule: median gas across the selected contract's fixed benchmark calls
- secondary outputs to keep once the runner is generalized:
  - per-case gas
  - worst-case gas
  - optional bytecode size
- invariant coverage now exists for all three initial gas-pack contracts:
  - `test/gas_pack/TokenLedgerInvariant.t.sol`
  - `test/gas_pack/RewardDistributorInvariant.t.sol`
  - `test/gas_pack/MerkleClaimerInvariant.t.sol`
- snapshot note:
  - use `forge snapshot --offline` for local gas-pack snapshots in this environment

## 5. Extend The Runner For V2

- [x] Generalize the experiment runner so it can target a selected V2 contract arena.
- [x] Emit structured output that is useful for both humans and automation.
- [x] Support per-contract benchmark selection without widening the editable surface.
- [x] Preserve crash classification, timeout handling, and deterministic result logging.
- [x] Keep the runner simpler than the arena it orchestrates.

Current runner behavior:

- `python scripts/run_gas_experiment.py` still runs the V1 path by default
- `python scripts/run_gas_experiment.py --arena gas_pack --target TokenLedger` runs the V2 path for one selected contract
- `python scripts/run_gas_benchmark.py --arena gas_pack --target RewardDistributor` runs the target-specific benchmark only
- benchmark snapshots use `--offline` by default to avoid the local Foundry proxy crash seen with plain `forge snapshot`

## 6. Build The First V2 Baseline

- [x] Run the first V2 contract end to end.
- [x] Confirm compilation, tests, invariants, and metric extraction all work.
- [x] Record the first V2 baseline in a V2-specific results log.
- [x] Treat that result as the first score to beat for the chosen V2 contract.
- [x] Do not start V2 optimization until the baseline is real.

Current first V2 baseline:

- target: `TokenLedger`
- commit: `5520615`
- results log: `results.gas_pack.tsv`
- baseline `median_gas`: `835526`
- per-case benchmark gas:
  - `testGasTokenLedgerMintBatch32`: `1155085`
  - `testGasTokenLedgerTransferFanout8`: `515968`
- invariants:
  - implemented later as part of phase 8 and now required for valid current V2 claims

## 7. Run The First V2 Search Pass

- [x] Choose one V2 contract as the first target.
- [x] Run a disciplined keep-or-discard loop on that contract only.
- [x] Log all V2 attempts cleanly.
- [x] Stop only when the local frontier goes flat for that target.
- [x] Summarize whether V2 is already producing more credible wins than V1.

Current first V2 search-pass summary:

- target: `TokenLedger`
- baseline start: `835526`
- kept improvement:
  - commit: `ee43f7a`
  - description: `load mintBatch inputs from calldata`
  - improved `median_gas`: `813699`
- discarded attempts:
  - `be71b13` - `unchecked mintBatch loop increment`
  - `9261f83` - `add single-mint fast path`
- current kept TokenLedger state:
  - code state restored to the kept path after discards
  - results log retained all attempts in `results.gas_pack.tsv`
- interpretation:
  - this first pass established the initial proof that V2 could produce a kept win on a realistic contract pattern
  - later phases extended that result to the full initial pack with invariant-style validation and stronger-comparator evidence

## 8. Strengthen Validation

- [x] Add invariant checks for at least one V2 contract.
- [x] Make invariant success a required condition for valid optimization claims.
- [x] Ensure failures are surfaced clearly in the runner output.
- [x] Prevent "gas wins" that only come from weakening correctness.

This phase is what should make V2 more defensible than V1.

Current invariant coverage:

- `TokenLedger` now has a dedicated invariant-style harness in `test/gas_pack/TokenLedgerInvariant.t.sol`
- `RewardDistributor` now has a dedicated invariant-style harness in `test/gas_pack/RewardDistributorInvariant.t.sol`
- `MerkleClaimer` now has a dedicated invariant-style harness in `test/gas_pack/MerkleClaimerInvariant.t.sol`
- the runner executes the target-specific invariant step for each current `gas_pack` contract
- invariant failure is surfaced as `reason: invariant_failure`
- invariant timeout is surfaced as `reason: invariant_timeout`
- invariant success is now part of the required validation surface for all three current gas-pack targets

## 9. Keep The Arena Narrow

- [x] Keep one editable target per search pass.
- [x] Avoid turning the V2 pack into a generic framework too early.
- [x] Do not mix security, strategy, and protocol research into the V2 gas-pack loop.
- [x] Keep local execution deterministic and offline.
- [x] Keep the implementation understandable enough that further arenas can reuse the same pattern.

Current phase 9 discipline:

- V2 search passes currently target one contract at a time
- benchmark execution remains local and offline
- the runner is still arena-specific rather than generic multi-research infrastructure
- the repo has not mixed gas-pack work with security or strategy research loops

## 10. Define What Counts As Meaningful

- [x] State the bar for a meaningful V2 result in the docs.
- [x] Require V2 to beat obvious manual baselines on realistic patterns before stronger claims are made.
- [x] Distinguish clearly between "working infrastructure" and "meaningful blockchain research result."
- [x] Capture the strongest open question for V3 after the first V2 pass is complete.

Current phase 10 definition:

- current honest repo state:
  - working V2 infrastructure with early promising results
- not yet justified:
  - broad autonomous blockchain research success claims
- strongest current V3-facing open question:
  - after gas-pack validation across multiple realistic contracts, should the next arena expand toward security or invariant discovery rather than more gas patterns

## 11. V2 Wrap-Up

- [x] Leave the branch at the best kept V2 state reached so far.
- [x] Ensure the V2 results log reflects all completed attempts.
- [x] Summarize the best V2 result and what it does or does not prove.
- [x] Record the next strongest contract or arena to add.
- [x] Suggest a commit message after substantial work.

Current phase 11 wrap-up:

- current branch head:
  - `d796faa`
- best kept V2 optimization commit:
  - `cdf7283`
- best kept V2 pack results:
  - `TokenLedger`
  - best `median_gas`: `813699`
  - baseline `median_gas`: `835526`
  - net improvement: `21827`
  - `RewardDistributor`
  - best `median_gas`: `862368`
  - baseline `median_gas`: `887232`
  - net improvement: `24864`
  - `MerkleClaimer`
  - best `median_gas`: `236051`
  - baseline `median_gas`: `250228`
  - net improvement: `14177`
- what this proves:
  - the repo has a working V2 gas-pack loop with kept wins across all three initial realistic contract patterns
  - stronger validation now exists across the pack through invariant-style checking
  - all three current gas-pack targets beat their frozen stronger manual comparators
- what this does not prove:
  - superiority over stronger manual comparators beyond the current fixed pack
  - a generally reliable autonomous blockchain research system
- next strongest contract to add or search:
  - a fourth realistic contract pattern, starting with vault-style accounting
- suggested tranche commit message:
  - `feat: finish stronger-comparator gas_pack tranche`

## 12. Achieve Broader Success Across Realistic Contract Patterns

This phase is the bridge between:

- working V2 infrastructure with early promising results

and:

- a more defensible claim of broader success across realistic contract patterns

The point is not to add many more contracts blindly.

The point is to show that the same disciplined loop works repeatedly on different realistic smart-contract patterns under comparable validation.

### 12.1 RewardDistributor tranche

- [x] Add invariant-style validation for `RewardDistributor`.
- [x] Ensure the runner treats that invariant step as required for valid `RewardDistributor` optimization claims.
- [x] Record the first `RewardDistributor` baseline in `results.gas_pack.tsv` or a clearly documented successor log.
- [x] Run a disciplined keep-or-discard search pass on `RewardDistributor`.
- [x] Leave the branch at the best kept `RewardDistributor` state reached so far.

Current `RewardDistributor` baseline:

- baseline commit: `ffa7fae`
- baseline `median_gas`: `887232`
- per-case benchmark gas:
  - `testGasRewardDistributorClaimAfterDeposit16`: `931288`
  - `testGasRewardDistributorSetShares16`: `843177`

Current `RewardDistributor` search-pass summary:

- baseline start: `887232`
- kept improvements:
  - `0d8f59f` - `specialize setShares zero-accrual path`
  - improved `median_gas`: `862368`
- discarded attempts:
  - `c26833e` - `cache reward accumulator in setShares`
  - `e590b35` - `unchecked setShares loop increment`
  - `fea6933` - `inline reward claim accrual path`
- current kept RewardDistributor state:
  - current kept branch state includes the specialized zero-accrual `setShares` path
- interpretation:
  - `RewardDistributor` is no longer flat overall
  - the kept win came from a benchmark-aware structural change rather than a micro loop cleanup

### 12.2 MerkleClaimer tranche

- [x] Add invariant-style validation for `MerkleClaimer`.
- [x] Ensure the runner treats that invariant step as required for valid `MerkleClaimer` optimization claims.
- [x] Record the first `MerkleClaimer` baseline in `results.gas_pack.tsv` or a clearly documented successor log.
- [x] Run a disciplined keep-or-discard search pass on `MerkleClaimer`.
- [x] Leave the branch at the best kept `MerkleClaimer` state reached so far.

Current `MerkleClaimer` baseline:

- baseline commit: `11f5a1f`
- baseline `median_gas`: `250228`
- per-case benchmark gas:
  - `testGasMerkleClaimerClaimDepth3`: `250228`

Current `MerkleClaimer` search-pass summary:

- baseline start: `250228`
- kept improvements:
  - `fedb18f` - `inline merkle verification into claim`
  - improved `median_gas`: `245771`
- discarded attempts:
  - `71852b2` - `unchecked merkle proof loop increment`
- current kept MerkleClaimer state:
  - current kept branch state inlines proof verification into `claim`
- interpretation:
  - `MerkleClaimer` is no longer flat overall
  - the kept win came from a structural claim-path change rather than a cosmetic loop tweak

### 12.3 Manual baseline comparison

- [x] Define what counts as an "obvious manual baseline" for `TokenLedger`.
- [x] Define what counts as an "obvious manual baseline" for `RewardDistributor`.
- [x] Define what counts as an "obvious manual baseline" for `MerkleClaimer`.
- [x] Record whether the best kept V2 versions beat those manual baselines on fixed local benchmarks.
- [x] Reflect those comparisons in the docs without overstating what the evidence proves.

Current manual baseline policy:

- use the first validated, readability-first kept implementation for each contract as the current repository manual baseline
- compare later candidates only under the same fixed benchmark and validation surface
- treat this as a practical repo baseline, not as proof of superiority over an expert external implementation

Current manual baseline outcomes:

- `TokenLedger`
  - baseline: `835526`
  - best kept: `813699`
  - outcome: beat baseline
- `RewardDistributor`
  - baseline: `887232`
  - best kept: `862368`
  - outcome: beat baseline
- `MerkleClaimer`
  - baseline: `250228`
  - best kept: `245771`
  - outcome: beat baseline

### 12.4 Cross-contract evidence

- [x] Summarize the best kept result for each current gas-pack contract in one place.
- [x] Show that wins are not confined to a single cherry-picked target.
- [x] Note where one contract failed to improve or stayed flat if that happens.
- [x] Keep the benchmark and validation surfaces fixed while making the comparison.
- [x] Avoid introducing new contract patterns until the current pack has been evaluated honestly.

Current cross-contract evidence summary:

- all three initial gas-pack contracts now have:
  - correctness tests
  - invariant-style validation
  - fixed benchmark coverage
  - recorded baselines
  - at least one completed search pass
- result spread:
  - `TokenLedger` improved
  - `RewardDistributor` improved after a deeper second pass
  - `MerkleClaimer` improved after a deeper second pass
- interpretation:
  - the repo no longer relies on one cherry-picked target for all evidence
  - the evidence now supports broad success across the current initial gas-pack contract patterns relative to the repository baseline policy

### 12.5 Broader-success decision

- [x] Decide whether the repo now has enough evidence to claim broader success across realistic contract patterns.
- [x] If yes, update `scope.md`, `README.md`, and `context.md` with the stronger claim boundary.
- [x] If no, state exactly what evidence is still missing.
- [x] Record the next most valuable addition after the current contract pack is fully evaluated.

Current broader-success gap:

- the current manual baseline policy is still repo-internal rather than an external expert comparator
- stronger comparator evidence is still missing

Current broader-success decision:

- decision: justified relative to the current initial gas-pack contract patterns and repository baseline policy
- reason:
  - `TokenLedger`, `RewardDistributor`, and `MerkleClaimer` now all have kept wins against their fixed repository baselines
  - all three current contracts also have invariant-style validation and completed search passes
  - the repo now has cross-contract evidence rather than a single winning example
- next most valuable addition:
  - benchmark explicit stronger manual comparators so the claim can move beyond repository-baseline success

## 13. Stronger Manual Comparators And Second-Pass Searches

This phase is about moving beyond the current repository-internal baseline policy.

The goal is to answer a harder question:

- can the loop beat a stronger, explicitly chosen manual implementation style rather than only beating the repo's first validated draft

### 13.1 Stronger manual comparator policy

- [x] Define a stronger manual comparator style for `TokenLedger`.
- [x] Define a stronger manual comparator style for `RewardDistributor`.
- [x] Define a stronger manual comparator style for `MerkleClaimer`.
- [x] Explain how those stronger comparators differ from the current repository baseline policy.
- [x] Record where the repo still lacks evidence against those stronger comparators.

Working definition for the next tranche:

- a stronger manual comparator should be a plausible careful human gas-aware implementation, not merely the first readable draft
- it should still live under the same fixed benchmark and validation surface
- it should be documented explicitly so later claims are auditable

Current stronger comparator definitions:

- `TokenLedger`
  - comparator style: careful human specialization of common mint and transfer paths with reduced repeated reads and unnecessary writes
- `RewardDistributor`
  - comparator style: careful human specialization of zero-accrual setup and claim-path accounting hot spots
- `MerkleClaimer`
  - comparator style: careful human specialization of proof traversal and claim-state handling hot spots

Current stronger-comparator evidence gap:

- the repo still needs to keep the stronger-comparator claim boundary explicit and limited to the current fixed pack
- the next open question is whether to strengthen comparator quality further or expand to a new contract pattern

### 13.2 RewardDistributor second-pass search

- [x] Run a deeper second-pass search on `RewardDistributor`.
- [x] Try at least one structural claim-path idea, not only loop micro-cleanups.
- [x] Keep the branch at the best validated `RewardDistributor` state reached so far.
- [x] Record whether the second pass remains flat or finds a kept win.

Current second-pass `RewardDistributor` note:

- structural idea tried:
  - `fea6933` - `inline reward claim accrual path`
- outcome:
  - discarded, worse than the current validated baseline
  - `0d8f59f` - `specialize setShares zero-accrual path`
  - kept, improved on both `RewardDistributor` benchmark cases

### 13.3 MerkleClaimer second-pass search

- [x] Decide whether `MerkleClaimer` deserves a deeper second pass now or should wait until stronger comparators are defined.
- [x] If it gets a second pass, try at least one structural proof-verification or claim-state idea.
- [x] Record whether that deeper pass remains flat or finds a kept win.

Current `MerkleClaimer` second-pass decision:

- it deserves a deeper second pass now
- reason:
  - stronger comparator expectations are now documented
  - `MerkleClaimer` was the only current gas-pack contract still flat before the second pass
  - the next credibility gain came from testing a structural claim-path change rather than another cosmetic tweak
- second-pass outcome:
  - `fedb18f` - `inline merkle verification into claim`
  - kept, improved the `MerkleClaimer` benchmark from `250228` to `245771`

### 13.4 Freeze and benchmark stronger manual comparators

- [x] Freeze an explicit stronger manual comparator implementation for `TokenLedger`.
- [x] Freeze an explicit stronger manual comparator implementation for `RewardDistributor`.
- [x] Freeze an explicit stronger manual comparator implementation for `MerkleClaimer`.
- [x] Validate those comparator contracts under the same correctness and invariant-style surface.
- [x] Benchmark those comparator contracts under the same fixed gas-pack benchmark cases.
- [x] Record whether the current kept contracts beat those stronger comparators.

Current frozen stronger comparator artifacts:

- contracts:
  - `contracts/gas_pack/manual/TokenLedgerManualComparator.sol`
  - `contracts/gas_pack/manual/RewardDistributorManualComparator.sol`
  - `contracts/gas_pack/manual/MerkleClaimerManualComparator.sol`
- correctness tests:
  - `test/gas_pack/TokenLedgerManualComparator.t.sol`
  - `test/gas_pack/RewardDistributorManualComparator.t.sol`
  - `test/gas_pack/MerkleClaimerManualComparator.t.sol`
- invariant-style tests:
  - `test/gas_pack/TokenLedgerManualComparatorInvariant.t.sol`
  - `test/gas_pack/RewardDistributorManualComparatorInvariant.t.sol`
  - `test/gas_pack/MerkleClaimerManualComparatorInvariant.t.sol`
- benchmark surface:
  - `test/gas_pack/GasPackManualComparatorBenchmark.t.sol`
  - `python scripts/run_gas_benchmark.py --arena gas_pack --target <Target> --benchmark-suite manual`

Current stronger-comparator outcomes:

- `TokenLedger`
  - current kept: `813699`
  - stronger manual comparator: `831827`
  - outcome: current kept contract beat the frozen stronger comparator
- `RewardDistributor`
  - current kept: `862368`
  - stronger manual comparator: `894867`
  - outcome: current kept contract beat the frozen stronger comparator
- `MerkleClaimer`
  - current kept: `236051`
  - stronger manual comparator: `236456`
  - outcome: current kept contract beat the frozen stronger comparator

### 13.5 Stronger-comparator decision

- [x] Decide whether the repo now has enough evidence to claim success against stronger manual comparators across the current gas pack.
- [x] If not, state exactly which contract still fails that stronger bar.
- [x] Record the next most valuable search target under the stronger-comparator standard.

Current stronger-comparator decision:

- decision: justified across the full current gas pack
- reason:
  - `TokenLedger`, `RewardDistributor`, and `MerkleClaimer` now all beat their frozen stronger manual comparators
  - `MerkleClaimer` cleared the last remaining stronger-comparator gap with `cdf7283` - `make merkle root immutable`
- next most valuable search target:
  - define whether the next tranche should deepen comparator quality further or add a fourth realistic contract pattern

## 14. Clear The Stronger-Comparator Bar

This phase is about closing the one remaining gap inside the current fixed pack.

The point is not to broaden the arena yet.

The point is to see whether the current loop can beat the frozen stronger manual comparator on the last remaining contract pattern.

### 14.1 MerkleClaimer third-pass search

- [x] Run a dedicated third-pass search on `MerkleClaimer` against the stronger-comparator bar.
- [x] Treat the frozen stronger comparator `median_gas = 236456` as the score to beat, not only the repository baseline.
- [x] Try at least one structural proof-hashing idea in `contracts/gas_pack/MerkleClaimer.sol`.
- [x] Only escalate to a separate claim-state write-path attempt if the proof-path changes do not clear the bar.
- [x] Keep or discard each attempt using the stronger-comparator bar plus the existing validation surface.
- [x] Leave the branch at the best validated `MerkleClaimer` state reached so far.
- [x] Record all stronger-comparator attempts in `results.gas_pack.tsv` or a clearly documented successor log.

Current `MerkleClaimer` stronger-comparator gap:

- current kept result: `236051`
- frozen stronger comparator: `236456`
- outcome:
  - cleared with `cdf7283` - `make merkle root immutable`
  - current kept contract now beats the frozen stronger comparator by `405`

### 14.2 Stronger-comparator pack decision

- [x] Decide whether all three current gas-pack contracts now beat their frozen stronger manual comparators.
- [x] If yes, update `scope.md` and `README.md` to state that stronger-comparator success is justified for the current fixed pack.
- [x] If no, keep the claim boundary unchanged and state exactly which contract still fails that bar.
- [x] Record the next most valuable move after the decision.

Current decision gate:

- settled:
  - all three current gas-pack contracts now beat their frozen stronger manual comparators
  - the stronger-comparator success claim should still stay limited to the current fixed pack

## 15. Decide Whether To Expand The Pack

This phase should only begin after phase 14 is settled.

The repo should not add breadth just to avoid the remaining harder comparison.

### 15.1 Expansion decision

- [x] Decide whether the next move should be:
  - adding a fourth realistic contract pattern
  - or strengthening comparator quality further for the current three
- [x] If a fourth contract is added, define it explicitly before implementation.
- [x] Do not start that expansion until the current stronger-comparator claim boundary is settled.

Suggested expansion candidates once phase 14 is complete:

- a vault-style accounting contract
- a staking or delegation accounting contract

Current expansion decision:

- decision:
  - add a fourth realistic contract pattern before deepening comparator quality further for the current three
- reason:
  - the current fixed pack has already cleared the stronger-comparator bar
  - the higher-value next evidence is breadth across one more realistic pattern, not more refinement inside the same three
  - vault-style accounting was already the leading deferred candidate from the initial V2 pack decision
- chosen fourth contract pattern:
  - a vault-style accounting contract
- immediate next tranche:
  - define the vault contract benchmark cases, correctness tests, and invariant surface before implementation
- scope guard:
  - do not start ZK or other new arena work until the fourth-contract gas-pack definition is written down

## 16. Define The Fourth Gas-Pack Target

This phase defines the next realistic contract pattern without pretending it is already implemented.

The point is to keep the repo narrow while making the fourth target concrete enough to build and benchmark cleanly.

### 16.1 VaultAccounting target definition

- [x] Choose the explicit fourth target name.
- [x] Decide whether the fourth target should be a narrow accounting vault or a broader ERC4626-style framework.
- [x] Define the fixed contract surface before implementation.
- [x] Define the benchmark shape before implementation.
- [x] State the main scope restrictions that keep the vault tranche interpretable.

Current `VaultAccounting` definition:

- target name:
  - `VaultAccounting`
- target shape:
  - a narrow share-based vault accounting contract
- fixed contract surface:
  - `deposit(address account, uint256 assets)`
  - `withdraw(address account, uint256 assets)`
  - `redeem(address account, uint256 shares)`
  - one explicit exchange-rate movement path such as `donate(uint256 assets)`
- benchmark shape:
  - bootstrap deposit into an empty vault
  - deposit after exchange-rate movement
  - partial withdraw against an existing position
  - full redeem after exchange-rate movement
- scope restrictions:
  - no strategy integration
  - no allowances or transfer layer
  - no fee logic
  - no rebasing behavior
  - keep one editable target per search pass

### 16.2 VaultAccounting implementation tranche

- [x] Add `contracts/gas_pack/VaultAccounting.sol`.
- [x] Add `test/gas_pack/VaultAccounting.t.sol`.
- [x] Add `test/gas_pack/VaultAccountingInvariant.t.sol`.
- [x] Add fixed `testGasVaultAccounting...` benchmark cases to `test/gas_pack/GasPackBenchmark.t.sol`.
- [x] Extend `scripts/run_gas_experiment.py` to accept `--target VaultAccounting`.
- [x] Extend `scripts/run_gas_benchmark.py` to accept `--target VaultAccounting`.
- [x] Record the first `VaultAccounting` baseline in `results.gas_pack.tsv`.
- [x] Only begin the first `VaultAccounting` keep-or-discard search pass after that baseline is real.

Implementation notes:

- keep the rounding policy explicit and fixed before benchmarking
- treat exchange-rate movement as a deterministic accounting path, not a live strategy integration
- the runner now points at the dedicated `VaultAccounting` contract/test/invariant files already present in the workspace
- current validated baseline for the active vault definition:
  - commit anchor: `d796faa`
  - `median_gas = 480638`
  - worst case:
    - `testGasVaultAccountingWithdrawExactAssets = 490816`
- first kept `VaultAccounting` search-pass result:
  - description:
    - `cache withdraw numerator and unchecked additions`
  - improved `median_gas`:
    - `464831`
  - improvement:
    - `15807`
- append-only vault baseline history currently includes earlier scaffold and pre-guard entries
- manual comparator files are deferred until the fourth target baseline exists

## 17. Define A Future ZK Arena

This phase is future-facing.

It should not interfere with the ongoing `gas_pack` search loop, but it should make the next non-gas arena concrete enough to build later.

### 17.1 Choose The ZK Arena Shape

- [x] Decide whether the first ZK arena should optimize:
  - verifier gas
  - proving time
  - or constraint count
- [x] Keep the first ZK arena to one proof-system family only.
- [x] Keep the first ZK arena to one editable target per pass.
- [x] Choose one primary metric only.

Recommended default:

- first ZK arena: `zk_verifier_pack`
- proof-system scope: one verifier family only
- primary metric: median gas across a fixed verification benchmark suite

Current phase 17.1 decision:

- first ZK arena:
  - `zk_verifier_pack`
- optimization mode:
  - verifier gas
- proof-system scope:
  - one verifier family only
- editable surface:
  - one verifier contract or verifier helper target per pass
- primary metric:
  - median gas across a fixed local verification benchmark suite
- reason:
  - this is the closest ZK analogue to the current `gas_pack` model and preserves local deterministic benchmarking

### 17.2 Define The ZK Validation Surface

- [x] Freeze a small valid-proof fixture set.
- [x] Freeze a small invalid-proof fixture set.
- [x] Define the correctness rule:
  - valid proofs must verify
  - invalid proofs must fail
- [x] Keep those fixtures fixed during any future ZK search pass.

The point is to prevent fake wins that only weaken verification logic.

Current phase 17.2 validation decision:

- valid-proof fixtures:
  - freeze `2` fixed valid fixtures for the first verifier family
  - one should be the baseline benchmark path used for gas measurement
  - one should be a second accepted case with different public inputs to prevent overfitting to a single fixture
- invalid-proof fixtures:
  - freeze `3` fixed invalid fixtures
  - invalid category 1:
    - wrong public inputs paired with an otherwise valid-looking proof
  - invalid category 2:
    - corrupted proof bytes or points that fail verification
  - invalid category 3:
    - structurally malformed proof or calldata layout that must be rejected cleanly
- correctness rule:
  - every valid fixture must verify
  - every invalid fixture must fail
- fixture discipline:
  - fixtures stay frozen during any future ZK search pass
  - do not generate fresh proofs during benchmark runs
  - do not depend on remote provers or nondeterministic setup steps

### 17.3 Define The First ZK Target

- [x] Choose the first editable target explicitly.
- [x] Decide whether it should be:
  - a full verifier contract
  - or a verifier helper / proof-decoding helper
- [x] Record why that target is the highest-signal first hotspot.

Recommended default:

- first target type:
  - a narrow verifier contract or verifier helper
- reason:
  - it fits the existing local benchmark-and-keep/discard model better than a prover or circuit arena

Current phase 17.3 target decision:

- first editable target:
  - a full verifier contract
- verifier family:
  - one BN254 Groth16-style verifier family only
- reason:
  - a full verifier contract matches the repo's current benchmark-contract workflow better than an isolated helper
  - it preserves end-to-end verification semantics while still keeping the editable surface to one file per pass
  - it gives a cleaner meaningful-result story than optimizing a helper in isolation

Expected future file layout:

- `contracts/zk_verifier_pack/<VerifierTarget>.sol`
- `test/zk_verifier_pack/<VerifierTarget>.t.sol`
- `test/zk_verifier_pack/<VerifierTarget>Invariant.t.sol`
- `test/zk_verifier_pack/ZKVerifierPackBenchmark.t.sol`
- `scripts/run_zk_verifier_benchmark.py`

### 17.4 Set The ZK Meaningful-Result Bar

- [x] Define what counts as a meaningful ZK result in this repo.
- [x] Require frozen valid/invalid fixtures before stronger ZK claims.
- [x] Decide when a stronger manual comparator becomes necessary for the ZK arena.

Suggested default:

- a meaningful first ZK result means:
  - verifier gas improves on a fixed local benchmark
  - valid proofs still verify
  - invalid proofs still fail
  - the benchmark and fixtures stay fixed during the pass

## 18. Scaffold The First ZK Verifier Arena

This phase should turn the current ZK planning work into a concrete but still narrow local scaffold.

The point is not to prove the whole ZK thesis yet.

The point is to create the first deterministic verifier-gas arena that can eventually support a baseline and keep-or-discard loop.

### 18.1 Define The Initial File Layout

- [x] Decide the exact first verifier target name.
- [x] Decide whether fixtures should live:
  - inline in Solidity tests
  - or in a dedicated Solidity fixture helper
- [x] Define the first benchmark contract path.
- [x] Define the first correctness test path.
- [x] Define the first invariant or rejection-surface test path.

Recommended default:

- target path:
  - `contracts/zk_verifier_pack/<VerifierTarget>.sol`
- correctness tests:
  - `test/zk_verifier_pack/<VerifierTarget>.t.sol`
- fixture helper:
  - `test/zk_verifier_pack/ZKVerifierFixtures.sol`
- benchmark:
  - `test/zk_verifier_pack/ZKVerifierPackBenchmark.t.sol`
- validation:
  - keep fixtures in Solidity first for maximum local determinism and minimal tooling spread

Current phase 18.1 file-layout decision:

- first verifier target name:
  - `BN254Groth16Verifier`
- contract path:
  - `contracts/zk_verifier_pack/BN254Groth16Verifier.sol`
- fixture location:
  - `test/zk_verifier_pack/ZKVerifierFixtures.sol`
- correctness test path:
  - `test/zk_verifier_pack/BN254Groth16Verifier.t.sol`
- rejection-surface test path:
  - `test/zk_verifier_pack/BN254Groth16VerifierRejection.t.sol`
- benchmark path:
  - `test/zk_verifier_pack/ZKVerifierPackBenchmark.t.sol`
- reason:
  - a dedicated Solidity fixture helper keeps valid and invalid artifacts frozen in-repo without adding a second toolchain dependency just to load fixtures

### 18.2 Define The First Benchmark Surface

- [x] Choose the benchmarked valid-verification path.
- [x] Decide whether to include one or two additional valid verification cases as secondary outputs.
- [x] Decide whether invalid fixtures belong in the gas benchmark or only in correctness validation.
- [x] Keep one primary metric only.

Recommended default:

- primary benchmark path:
  - one fixed valid verification case
- secondary valid cases:
  - one additional accepted case with different public inputs
- invalid fixtures:
  - correctness validation only, not part of the gas metric aggregation
- primary metric:
  - median gas across the fixed valid verification benchmark cases

Current phase 18.2 benchmark decision:

- benchmarked primary valid path:
  - one fixed accepted verification case for `BN254Groth16Verifier`
- secondary valid path count:
  - one additional accepted case with different public inputs
- invalid-fixture placement:
  - correctness validation only
- primary metric:
  - median gas across the `2` fixed valid verification benchmark cases
- reason:
  - gas should measure accepted verification work only, while invalid fixtures remain part of semantic validation rather than the optimization target

### 18.3 Define The First Local Runner Plan

- [x] Decide whether to extend the current runner or add a ZK-specific runner.
- [x] Define the minimum commands needed to run:
  - correctness validation
  - invalid-fixture rejection checks
  - gas benchmark extraction
- [x] Keep the runner simpler than the verifier arena it orchestrates.

Recommended default:

- runner style:
  - add a ZK-specific runner rather than overloading the gas-pack runner immediately
- likely script path:
  - `scripts/run_zk_verifier_benchmark.py`

Current phase 18.3 runner decision:

- runner style:
  - add a ZK-specific runner
- likely script paths:
  - `scripts/run_zk_verifier_benchmark.py`
  - `scripts/run_zk_verifier_experiment.py`
- minimum command plan:
  - run correctness tests for `BN254Groth16Verifier`
  - run rejection-surface tests against the frozen invalid fixtures
  - run the fixed valid verification benchmark contract and extract gas metrics
- scope guard:
  - do not overload the existing `gas_pack` runner with ZK-specific fixture logic in the first ZK scaffold

Current phase 17.4 decision:

- a meaningful first ZK result requires:
  - improved verifier gas on a fixed local benchmark suite
  - frozen valid and invalid fixture sets
  - unchanged verification semantics across the pass
  - one fixed verifying key and fixed benchmark call set during the pass
- stronger-comparator rule:
  - require a stronger manual comparator after the first working ZK baseline and first kept win exist
  - the comparator should be a careful human gas-aware verifier implementation under the same frozen fixtures

## 19. Define The First ZK Artifact Surface

This phase should turn the current verifier-arena scaffold into a concrete implementation contract.

The point is to decide the exact artifact format and function surface before writing the first ZK verifier files.

### 19.1 Define The Fixture Artifact Format

- [x] Decide how `ZKVerifierFixtures.sol` should represent:
  - the verifying key
  - each valid proof fixture
  - each invalid proof fixture
- [x] Decide whether fixture access should be exposed as:
  - named getter functions
  - or Solidity structs returned by helper functions
- [x] Keep the fixture format simple enough that benchmark and correctness tests can share it without conversion code.

Recommended default:

- encode fixtures as Solidity structs returned by named helper functions
- keep the verifying key in the same fixture helper for the first scaffold
- avoid JSON or off-chain parsing in the first arena

Current phase 19.1 fixture-format decision:

- fixture representation:
  - store the verifying key as a dedicated Solidity struct
  - store each valid fixture as a Solidity struct containing:
    - proof points
    - public inputs
    - expected outcome
  - store each invalid fixture as a Solidity struct containing:
    - proof points or malformed proof payload
    - public inputs when applicable
    - invalid category label
    - expected outcome
- access pattern:
  - expose named helper functions that return Solidity structs
- fixture helper shape:
  - one getter for the verifying key
  - one getter per valid fixture
  - one getter per invalid fixture
- reason:
  - this keeps the fixtures frozen, readable, and directly reusable from correctness tests, rejection tests, and the benchmark without an adapter layer

### 19.2 Define The Verifier Function Surface

- [x] Decide the exact public function name on `BN254Groth16Verifier`.
- [x] Decide the calldata shape for:
  - proof points
  - public inputs
- [x] Decide whether the first verifier target should expose:
  - one single verification entrypoint only
  - or a small helper surface in addition to that entrypoint
- [x] Keep the editable surface narrow enough that one contract file is still the whole optimization target.

Recommended default:

- one primary entrypoint:
  - `verifyProof(...)`
- one verification mode only
- no extra convenience wrappers in the first scaffold

Current phase 19.2 verifier-surface decision:

- public entrypoint:
  - `verifyProof(...)`
- public-input shape:
  - fixed-size Solidity arrays when the first verifier family allows a stable public-input count
- proof shape:
  - explicit calldata arguments for the Groth16 proof points rather than opaque bytes for the first scaffold
- surface size:
  - one verification entrypoint only
- reason:
  - explicit calldata arguments keep the first verifier arena interpretable and avoid pushing parsing complexity into a helper layer before the baseline exists

### 19.3 Define The Benchmark And Test Names

- [x] Decide the exact benchmark test names for the `2` fixed valid verification cases.
- [x] Decide the correctness-test names for accepted fixtures.
- [x] Decide the rejection-test names for each invalid fixture category.
- [x] Preserve the same naming discipline used by `gas_pack` so later runners can extract metrics predictably.

Recommended default:

- benchmark tests:
  - `testGasBN254Groth16VerifierValidCaseA`
  - `testGasBN254Groth16VerifierValidCaseB`
- correctness tests:
  - one acceptance test per valid fixture
- rejection tests:
  - one rejection test for wrong public inputs
  - one rejection test for corrupted proof data
  - one rejection test for malformed calldata or proof layout

Current phase 19.3 naming decision:

- benchmark tests:
  - `testGasBN254Groth16VerifierValidCaseA`
  - `testGasBN254Groth16VerifierValidCaseB`
- correctness tests:
  - `testVerifyProofAcceptsValidCaseA`
  - `testVerifyProofAcceptsValidCaseB`
- rejection tests:
  - `testVerifyProofRejectsWrongPublicInputs`
  - `testVerifyProofRejectsCorruptedProof`
  - `testVerifyProofRejectsMalformedProofLayout`
- naming rule:
  - reserve the `testGasBN254Groth16Verifier...` prefix for benchmark extraction only

### 19.4 Define The First Implementation Gate

- [x] State what must exist before the first ZK scaffold implementation counts as complete.
- [x] Keep the completion bar lower than a full optimization result but higher than a placeholder scaffold.

Suggested default:

- first scaffold counts as complete only when:
  - `BN254Groth16Verifier.sol` exists
  - `ZKVerifierFixtures.sol` provides frozen valid and invalid fixtures
  - correctness tests pass
  - rejection tests pass
  - the benchmark runs and emits the primary metric

Current phase 19.4 implementation gate:

- first ZK scaffold is complete only when:
  - the verifier contract exists at the chosen path
  - the fixture helper exposes the frozen verifying key plus `2` valid and `3` invalid fixtures
  - correctness tests confirm both valid fixtures verify
  - rejection tests confirm all `3` invalid categories fail
  - the benchmark contract emits gas metrics for the `2` valid benchmark cases
  - the dedicated ZK runner can execute the validation and benchmark path locally
- completion does not yet require:
  - a kept optimization win
  - a stronger manual comparator
  - more than one verifier family

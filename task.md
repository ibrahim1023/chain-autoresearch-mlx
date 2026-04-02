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
- [ ] Add invariant checks where practical.
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
  - none implemented yet, so correctness currently means compilation plus target-specific tests plus benchmark metric extraction

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
  - V2 is already more credible than V1 in the limited sense that the optimization is happening on a more realistic contract pattern than the toy single-contract arena
  - V2 is not yet strongly credible because invariant coverage is still missing and only one contract has been searched so far

## 8. Strengthen Validation

- [x] Add invariant checks for at least one V2 contract.
- [x] Make invariant success a required condition for valid optimization claims.
- [x] Ensure failures are surfaced clearly in the runner output.
- [x] Prevent "gas wins" that only come from weakening correctness.

This phase is what should make V2 more defensible than V1.

Current invariant coverage:

- `TokenLedger` now has a dedicated invariant-style harness in `test/gas_pack/TokenLedgerInvariant.t.sol`
- the runner executes that invariant step for `--arena gas_pack --target TokenLedger`
- invariant failure is surfaced as `reason: invariant_failure`
- invariant timeout is surfaced as `reason: invariant_timeout`
- `RewardDistributor` and `MerkleClaimer` still need comparable invariant coverage later

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
  - `1d81d05`
- best kept V2 optimization commit:
  - `ee43f7a`
- best kept V2 result:
  - target: `TokenLedger`
  - best `median_gas`: `813699`
  - baseline `median_gas`: `835526`
  - net improvement: `21827`
- what this proves:
  - the repo has a working V2 gas-pack loop with a real kept improvement on a more realistic contract pattern than V1
  - stronger validation now exists for that target through invariant-style checking
- what this does not prove:
  - broad success across realistic contract patterns
  - superiority over explicit manual baselines
  - a generally reliable autonomous blockchain research system
- next strongest contract to add or search:
  - `RewardDistributor`
- suggested tranche commit message:
  - `feat: complete initial gas_pack v2 tranche`

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

- the repo has not yet shown a clean sweep against frozen stronger manual comparators across all three current contracts
- the current stronger-comparator sweep is incomplete because `MerkleClaimer` still trails its frozen comparator

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
  - current kept: `245771`
  - stronger manual comparator: `236456`
  - outcome: frozen stronger comparator beat the current kept contract

### 13.5 Stronger-comparator decision

- [x] Decide whether the repo now has enough evidence to claim success against stronger manual comparators across the current gas pack.
- [x] If not, state exactly which contract still fails that stronger bar.
- [x] Record the next most valuable search target under the stronger-comparator standard.

Current stronger-comparator decision:

- decision: not yet justified across the full current gas pack
- reason:
  - `TokenLedger` and `RewardDistributor` beat their frozen stronger manual comparators
  - `MerkleClaimer` does not; the frozen stronger comparator remains better on the fixed benchmark
- next most valuable search target:
  - `MerkleClaimer`, now judged against the explicit stronger comparator rather than only the repository baseline

## 14. Clear The Stronger-Comparator Bar

This phase is about closing the one remaining gap inside the current fixed pack.

The point is not to broaden the arena yet.

The point is to see whether the current loop can beat the frozen stronger manual comparator on the last remaining contract pattern.

### 14.1 MerkleClaimer third-pass search

- [ ] Run a dedicated third-pass search on `MerkleClaimer` against the stronger-comparator bar.
- [ ] Treat the frozen stronger comparator `median_gas = 236456` as the score to beat, not only the repository baseline.
- [ ] Try at least one structural proof-hashing idea in `contracts/gas_pack/MerkleClaimer.sol`.
- [ ] Try at least one claim-state write-path idea in `contracts/gas_pack/MerkleClaimer.sol`.
- [ ] Keep or discard each attempt using the stronger-comparator bar plus the existing validation surface.
- [ ] Leave the branch at the best validated `MerkleClaimer` state reached so far.
- [ ] Record all stronger-comparator attempts in `results.gas_pack.tsv` or a clearly documented successor log.

Current `MerkleClaimer` stronger-comparator gap:

- current kept result: `245771`
- frozen stronger comparator: `236456`
- gap to close: `9315`

### 14.2 Stronger-comparator pack decision

- [ ] Decide whether all three current gas-pack contracts now beat their frozen stronger manual comparators.
- [ ] If yes, update `scope.md` and `README.md` to state that stronger-comparator success is justified for the current fixed pack.
- [ ] If no, keep the claim boundary unchanged and state exactly which contract still fails that bar.
- [ ] Record the next most valuable move after the decision.

Current decision gate:

- this section stays open until `MerkleClaimer` either beats `236456` or is honestly judged flat against that bar

## 15. Decide Whether To Expand The Pack

This phase should only begin after phase 14 is settled.

The repo should not add breadth just to avoid the remaining harder comparison.

### 15.1 Expansion decision

- [ ] Decide whether the next move should be:
  - adding a fourth realistic contract pattern
  - or strengthening comparator quality further for the current three
- [ ] If a fourth contract is added, define it explicitly before implementation.
- [ ] Do not start that expansion until the current stronger-comparator claim boundary is settled.

Suggested expansion candidates once phase 14 is complete:

- a vault-style accounting contract
- a staking or delegation accounting contract

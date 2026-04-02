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

- [ ] Keep one editable target per search pass.
- [ ] Avoid turning the V2 pack into a generic framework too early.
- [ ] Do not mix security, strategy, and protocol research into the V2 gas-pack loop.
- [ ] Keep local execution deterministic and offline.
- [ ] Keep the implementation understandable enough that further arenas can reuse the same pattern.

## 10. Define What Counts As Meaningful

- [ ] State the bar for a meaningful V2 result in the docs.
- [ ] Require V2 to beat obvious manual baselines on realistic patterns before stronger claims are made.
- [ ] Distinguish clearly between "working infrastructure" and "meaningful blockchain research result."
- [ ] Capture the strongest open question for V3 after the first V2 pass is complete.

## 11. V2 Wrap-Up

- [ ] Leave the branch at the best kept V2 state reached so far.
- [ ] Ensure the V2 results log reflects all completed attempts.
- [ ] Summarize the best V2 result and what it does or does not prove.
- [ ] Record the next strongest contract or arena to add.
- [ ] Suggest a commit message after substantial work.

# Context Anchor

Date: 2026-04-02

Project:
- Name: chain-autoresearch
- Purpose: Build a deterministic local blockchain autoresearch harness that can optimize realistic smart-contract implementations for gas under strong correctness constraints.

Current Status:
- Phase: Multi-contract evidence consolidation after completing initial tranches for `TokenLedger`, `RewardDistributor`, and `MerkleClaimer`.
- Current branch: `codex-gas-pack-v2`
- Current HEAD: `643393d`
- Honest repo state: working V2 infrastructure with multi-contract validation and baseline coverage, but not yet broad success across realistic contract patterns.

Completed In This Tranche:
- Aligned `AGENTS.md`, `program.md`, `README.md`, and `task.md` with the V2 `gas_pack` direction.
- Added V2 scaffold contracts:
  - `contracts/gas_pack/TokenLedger.sol`
  - `contracts/gas_pack/RewardDistributor.sol`
  - `contracts/gas_pack/MerkleClaimer.sol`
- Added V2 correctness tests and a fixed benchmark contract:
  - `test/gas_pack/TokenLedger.t.sol`
  - `test/gas_pack/RewardDistributor.t.sol`
  - `test/gas_pack/MerkleClaimer.t.sol`
  - `test/gas_pack/GasPackBenchmark.t.sol`
- Generalized the runner for V1 and V2 target-specific execution:
  - `scripts/run_gas_experiment.py`
  - `scripts/run_gas_benchmark.py`
- Recorded the first V2 baseline in `results.gas_pack.tsv`.
- Completed the first V2 search pass on `TokenLedger`.
- Added invariant-style validation for `TokenLedger` in `test/gas_pack/TokenLedgerInvariant.t.sol`.
- Added invariant-style validation for `RewardDistributor` in `test/gas_pack/RewardDistributorInvariant.t.sol`.
- Added invariant-style validation for `MerkleClaimer` in `test/gas_pack/MerkleClaimerInvariant.t.sol`.
- Documented the meaningful-result bar and narrow-arena discipline.
- Added a broader-success roadmap to `task.md`.

Best V2 Result So Far:
- Target: `TokenLedger`
- Best kept optimization commit: `ee43f7a`
- Best kept description: `load mintBatch inputs from calldata`
- Baseline `median_gas`: `835526`
- Best kept `median_gas`: `813699`
- Improvement: `21827`

V2 Attempt History:
- `5520615` - keep - `baseline TokenLedger gas_pack v2`
- `be71b13` - discard - `unchecked mintBatch loop increment`
- `ee43f7a` - keep - `load mintBatch inputs from calldata`
- `9261f83` - discard - `add single-mint fast path`
- `ffa7fae` - keep - `baseline RewardDistributor gas_pack v2`
- `c26833e` - discard - `cache reward accumulator in setShares`
- `e590b35` - discard - `unchecked setShares loop increment`
- `11f5a1f` - keep - `baseline MerkleClaimer gas_pack v2`
- `71852b2` - discard - `unchecked merkle proof loop increment`

Cross-Contract Status:
- `TokenLedger`
  - baseline: `835526`
  - best kept: `813699`
  - outcome: beat current repository manual baseline
- `RewardDistributor`
  - baseline: `887232`
  - best kept: `887232`
  - outcome: flat so far
- `MerkleClaimer`
  - baseline: `250228`
  - best kept: `250228`
  - outcome: flat so far

What The Current State Proves:
- The repo can run a realistic V2 gas-pack loop on multiple selected contracts.
- The repo can keep or discard changes against fixed local benchmarks.
- The repo can enforce stronger validation than V1 for all three current gas-pack contracts through invariant-style harnesses.
- The repo has at least one real V2 gas win on a more realistic contract pattern than the V1 toy arena.
- The repo can now report honest flat results instead of only reporting winners.

What It Does Not Yet Prove:
- Broad success across realistic contract patterns.
- Wins over stronger manual baselines beyond the repository reference implementations.
- A generally reliable autonomous blockchain optimizer.

Known Gaps:
- Only `TokenLedger` has a kept improvement so far.
- The current manual baseline policy is still repo-internal rather than an external expert comparator.
- A broader-success decision has not yet been written into the main docs.
- The worktree still has unrelated `.gitignore` changes and generated snapshot files that were intentionally left out of commits.

Next Best Steps:
- Keep the stronger-comparator claim boundary limited to the current fixed pack.
- Define the fourth gas-pack target explicitly as `VaultAccounting`.
- `VaultAccounting` now has a real local baseline with correctness tests, invariant checks, and benchmark wiring.
- `VaultAccounting` now also has an initial kept improvement from `480638` to `464831`.
- Continue the `VaultAccounting` keep-or-discard search pass from that kept state before moving to a stronger comparator or a new arena.
- For the next arena after gas work, the leading future candidate is a narrow `zk_verifier_pack` verifier-gas arena rather than broad ZK research.
- The ZK arena-shape decision is now set: verifier gas first, one verifier family only, one editable target per pass.
- The ZK validation-surface decision is now set: freeze `2` valid fixtures and `3` invalid fixtures, and keep them fixed across any future verifier-gas search pass.
- The current recommended first ZK target is a full BN254 Groth16-style verifier contract.
- The ZK meaningful-result bar is now explicit: gas must improve while the frozen valid and invalid fixtures keep the same verification outcomes.
- The first ZK scaffold layout is now set around `BN254Groth16Verifier`, `ZKVerifierFixtures.sol`, a dedicated rejection test file, a benchmark contract, and dedicated ZK runner scripts.

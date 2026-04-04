# Context Anchor

Date: 2026-04-04

Project:
- Name: chain-autoresearch
- Purpose: Build a deterministic local blockchain autoresearch harness that can optimize realistic smart-contract implementations for gas under strong correctness constraints.

Current Status:
- Phase: First real `zk_verifier_pack` optimization pass after the verifier scaffold and baseline.
- Current branch: `codex/zk-verifier-v3`
- Current HEAD: `5672957`
- Honest repo state: working V2 gas-pack infrastructure on `main`, plus a narrow ZK verifier-gas arena on the V3 branch with one real kept post-baseline improvement.

- Completed the V2 `gas_pack` work on `main`, including `VaultAccounting` and an initial kept vault improvement.
- Defined the V3 ZK direction as a narrow verifier-gas arena on `codex/zk-verifier-v3`.
- Added the first ZK verifier scaffold:
  - `contracts/zk_verifier_pack/BN254Groth16Verifier.sol`
  - `test/zk_verifier_pack/ZKVerifierFixtures.sol`
  - `test/zk_verifier_pack/BN254Groth16Verifier.t.sol`
  - `test/zk_verifier_pack/BN254Groth16VerifierRejection.t.sol`
  - `test/zk_verifier_pack/ZKVerifierPackBenchmark.t.sol`
- Added dedicated ZK runners:
  - `scripts/run_zk_verifier_benchmark.py`
  - `scripts/run_zk_verifier_experiment.py`
- Recorded the first ZK baseline in `results.zk_verifier_pack.tsv`.
- Kept the first real ZK verifier optimization result after validation.

Best ZK Result So Far:
- Target: `BN254Groth16Verifier`
- Best kept optimization commit: `5672957`
- Best kept description: `inline fixed verifier constants and reduce pairing work`
- Baseline `median_gas`: `223677`
- Best kept `median_gas`: `150360`
- Improvement: `73317`

ZK Attempt History:
- `6f4c816` - keep - `baseline BN254Groth16Verifier zk_verifier_pack v1`
- `5672957` - keep - `inline fixed verifier constants and reduce pairing work`

Current ZK Arena Status:
- `BN254Groth16Verifier`
  - baseline: `223677`
  - best kept: `150360`
  - outcome: first real post-baseline ZK verifier-gas win

What The Current State Proves:
- The repo can run a narrow local ZK verifier-gas arena end to end.
- The repo can keep or discard verifier changes against fixed valid and invalid fixtures.
- The repo can preserve semantic validation while improving accepted verification gas.
- The repo now has one real kept ZK improvement after a recorded baseline, not only planning docs.

What It Does Not Yet Prove:
- Broad success across ZK verifier families.
- Wins against stronger manual expert comparators for verifier implementations.
- A generally reliable autonomous blockchain optimizer across gas and ZK arenas.

Known Gaps:
- The ZK arena still has only one verifier family and one target.
- The current verifier is a narrow local scaffold rather than a full generated production verifier pipeline.
- The stronger-comparator bar for ZK has not yet been defined beyond the repo baseline.
- The branch still needs more than one keep/discard attempt before any broader claim would be credible.

Next Best Steps:
- Continue the `BN254Groth16Verifier` keep-or-discard loop from the new kept state at `150360`.
- Add at least one discard attempt or additional kept result so the ZK arena has a real early frontier rather than a single jump.
- Define the first stronger manual comparator policy for `zk_verifier_pack` after a few local attempts exist.
- Keep the ZK arena narrow until the verifier-gas loop is clearly repeatable.

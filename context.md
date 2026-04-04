# Context Anchor

Date: 2026-04-04

Project:
- Name: chain-autoresearch
- Purpose: Build a deterministic local blockchain autoresearch harness that can optimize realistic smart-contract implementations for gas under strong correctness constraints.

Current Status:
- Phase: ZK wrap-up after early-frontier discards and the frozen comparator claim-boundary decision.
- Current branch: `codex/zk-verifier-v3`
- Honest repo state: working V2 gas-pack infrastructure on `main`, plus a narrow ZK verifier-gas arena on the V3 branch with one real kept post-baseline improvement and a stronger frozen comparator that the current kept verifier does not beat.

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
- Added and benchmarked a frozen stronger manual comparator for the same BN254 fixture set.

Best ZK Result So Far:
- Target: `BN254Groth16Verifier`
- Best kept optimization commit: `5672957`
- Best kept description: `inline fixed verifier constants and reduce pairing work`
- Baseline `median_gas`: `223677`
- Best kept `median_gas`: `150360`
- Improvement: `73317`

Frozen ZK Comparator:
- Target: `BN254Groth16Comparator`
- Comparator commit: `4224858`
- Comparator description: `frozen stronger manual comparator BN254Groth16Comparator v1`
- Comparator `median_gas`: `33199`

ZK Attempt History:
- `6f4c816` - keep - `baseline BN254Groth16Verifier zk_verifier_pack v1`
- `5672957` - keep - `inline fixed verifier constants and reduce pairing work`
- `4224858` - keep - `frozen stronger manual comparator BN254Groth16Comparator v1`
- `b92299c` - crash - `try fixed-size precompile buffers through helper mutation`
- `b92299c` - crash - `try fixed-size precompile buffers with inline pairing input`

Current ZK Arena Status:
- `BN254Groth16Verifier`
  - baseline: `223677`
  - best kept: `150360`
  - outcome: first real post-baseline ZK verifier-gas win, but not a stronger-comparator win
- `BN254Groth16Comparator`
  - baseline: `33199`
  - best kept: `33199`
  - outcome: frozen stronger manual comparator bar for the current fixed fixture set

What The Current State Proves:
- The repo can run a narrow local ZK verifier-gas arena end to end.
- The repo can keep or discard verifier changes against fixed valid and invalid fixtures.
- The repo can preserve semantic validation while improving accepted verification gas.
- The repo now has one real kept ZK improvement after a recorded baseline, plus a frozen stronger comparator benchmark.
- The repo now also has a real early frontier with post-win failed attempts rather than only one successful jump.

What It Does Not Yet Prove:
- Broad success across ZK verifier families.
- A kept verifier win against the stronger frozen comparator bar.
- A generally reliable autonomous blockchain optimizer across gas and ZK arenas.

Known Gaps:
- The ZK arena still has only one verifier family and one target.
- The current verifier is a narrow local scaffold rather than a full generated production verifier pipeline.
- The current kept verifier does not beat the frozen stronger comparator.
- The branch would need a reopened main-target pass or a second ZK target to justify any broader claim.

Next Best Steps:
- Stop the ZK tranche here for now.
- If ZK is revisited later, reopen the main target for more search only after a new evidence bar is defined.
- The current comparator file is the strongest manual local reference for the fixed BN254 fixture set.

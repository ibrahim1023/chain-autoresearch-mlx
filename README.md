# chain-autoresearch

Deterministic local autoresearch for blockchain systems.

This repository adapts the autoresearch loop from ML-style experimentation to narrow blockchain arenas where one target is edited, benchmarked, validated, and either kept or discarded.

Original autoresearch shape:

- edit training code
- run experiment
- measure metric
- keep or discard

Current chain-autoresearch shape:

- edit one contract target
- run deterministic local validation and benchmark steps
- measure one primary metric
- keep or discard

## Current Scope

The current repository is intentionally narrow:

- deterministic local execution
- one editable target per search pass
- fixed benchmark fixtures and validation surfaces
- gas-focused smart-contract research arenas
- strong correctness constraints

It is not yet:

- a general-purpose blockchain research engine
- a broad autonomous protocol designer
- a live-chain experimentation system

## Current Results

The strongest current public claim is:

- the V2 `gas_pack` arena is real
- the initial fixed gas-pack targets have kept wins
- those current fixed-pack wins beat frozen stronger manual comparators
- the repo also has a real ZK verifier-gas arena
- the current ZK verifier win does not beat its stronger comparator

| Arena / Target | Baseline | Best kept | Improvement | Comparator status | Notes |
|---|---:|---:|---:|---|---|
| `TokenLedger` | `835526` | `813699` | `21827` | beat stronger comparator `831827` | invariant-checked |
| `RewardDistributor` | `887232` | `862368` | `24864` | beat stronger comparator `894867` | invariant-checked |
| `MerkleClaimer` | `250228` | `236051` | `14177` | beat stronger comparator `236456` | invariant-checked |
| `VaultAccounting` | `480638` | `464831` | `15807` | stronger comparator not defined yet | early fourth target |
| `BN254Groth16Verifier` | `223677` | `150360` | `73317` | does not beat stronger comparator `33199` | real ZK win, limited claim |

## Why This Repo Exists

Autoresearch showed that a narrow keep-or-discard loop can run repeated experiments against a fixed arena and metric.

This repository applies the same pattern to blockchain systems. Instead of optimizing model loss, it currently optimizes gas usage while preserving correctness inside deterministic local benchmark environments.

## What Changed From Autoresearch

| Concept | autoresearch | chain-autoresearch |
|---|---|---|
| Domain | ML training | blockchain experimentation |
| Editable target | training code | one contract target |
| Primary metric | validation/training metric | `median_gas` |
| Arena | model/data/training setup | fixed local benchmark and validation setup |
| Keep rule | metric improvement | gas improvement without correctness regression |

## How It Works

1. Choose one arena and one editable target.
2. Modify only that target during the pass.
3. Run fixed local tests, invariants, and benchmark commands.
4. Extract the primary metric.
5. Keep or discard the result.

```text
edit target -> run fixed benchmark -> validate correctness -> measure gas -> keep/discard
```

## Quickstart

### Requirements

- Python 3.10+
- Foundry

Optional:

- `uv` if you want to manage the Python environment through the checked-in `pyproject.toml`

### First Run

Clone the repo, then run one of the existing arena commands directly.

V1 baseline arena:

```bash
python scripts/run_gas_experiment.py
python scripts/run_gas_benchmark.py
```

V2 `gas_pack` benchmark for one target:

```bash
python scripts/run_gas_benchmark.py --arena gas_pack --target TokenLedger
python scripts/run_gas_experiment.py --arena gas_pack --target TokenLedger
```

V2 manual comparator benchmark for one target:

```bash
python scripts/run_gas_benchmark.py --arena gas_pack --target TokenLedger --benchmark-suite manual
```

ZK verifier benchmark:

```bash
python scripts/run_zk_verifier_benchmark.py --arena zk_verifier_pack --target BN254Groth16Verifier
python scripts/run_zk_verifier_experiment.py --arena zk_verifier_pack --target BN254Groth16Verifier
```

Results are recorded in:

- `results.gas.tsv`
- `results.gas_pack.tsv`
- `results.zk_verifier_pack.tsv`

## Arena Status

### V2 `gas_pack`

This is the strongest completed arena in the repo today.

What it currently supports:

- one editable contract at a time
- fixed benchmark fixtures
- correctness tests plus invariant-style validation
- append-only result logs
- stronger manual comparator benchmarks for the initial fixed pack

Current fixed-pack targets:

- `TokenLedger`
- `RewardDistributor`
- `MerkleClaimer`

Current expansion target:

- `VaultAccounting`

What the current `gas_pack` evidence supports:

- real kept wins across the initial fixed pack
- stronger-comparator wins for those fixed-pack targets
- a narrower credibility claim for realistic local gas optimization

What it does not support yet:

- broad success beyond the current fixed pack
- a generally reliable autonomous blockchain optimizer

### ZK Verifier Arena

The repo also contains a separate narrow verifier-gas arena:

- `zk_verifier_pack`

Current shape:

- one BN254 verifier family
- one verifier target
- fixed valid and invalid fixtures
- gas measurement for `verifyProof(...)`

Current evidence:

- baseline verifier `median_gas`: `223677`
- best kept verifier `median_gas`: `150360`
- stronger comparator `median_gas`: `33199`

The honest claim boundary is:

- the verifier arena is real
- it has one real post-baseline kept win
- the current kept verifier does not beat the stronger comparator

### V1 Reference Arena

The original implemented arena remains in the repo as baseline history:

- target: `contracts/GasCandidate.sol`
- tests: `test/GasCandidate.t.sol`
- benchmark: `test/GasBenchmark.t.sol`
- runner: `scripts/run_gas_experiment.py`

Best recorded V1 result:

- commit `e3160d8`
- `median_gas = 1502102`

## Fork Lineage

This repository started from an Apple Silicon friendly MLX fork of autoresearch.

That lineage still explains parts of the repository name and some legacy files, but the active project is now blockchain-first rather than ML-training-first.

## Legacy Files

The repository still contains MLX-era files such as:

- `prepare.py`
- `train.py`
- `results.tsv`

Those files remain part of repository history, not the active blockchain benchmark path.

## License

MIT. See [LICENSE](LICENSE).

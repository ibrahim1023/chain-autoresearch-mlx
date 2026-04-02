# chain-autoresearch

`chain-autoresearch` is a deterministic local blockchain autoresearch repository inspired by autoresearch.

The project runs narrow keep-or-discard experiment loops against a fixed local arena:

- one arena
- one editable target at a time
- one primary metric
- repeated local validation and comparison

## Current Status

The repository has already completed a first blockchain V1 arena:

- local smart-contract gas optimization
- one editable contract target
- one gas benchmark suite
- one primary gas metric

That V1 arena proved the basic local autoresearch loop works.

The active next step is V2:

- a more realistic `gas_pack` arena with stronger correctness guarantees and more credible contract patterns

## V1 Reference

The implemented V1 arena centers on:

- target: `contracts/GasCandidate.sol`
- tests: `test/GasCandidate.t.sol`
- benchmark: `test/GasBenchmark.t.sol`
- runner: `scripts/run_gas_experiment.py`
- primary metric: `median_gas`

Useful commands:

```bash
python scripts/run_gas_experiment.py
python scripts/run_gas_benchmark.py
forge test
```

V1 results are logged in:

- `results.gas.tsv`

Best recorded V1 result so far:

- commit `e3160d8`
- `median_gas = 1502102`

## V2 Direction

V2 is not "more runs on the toy contract."

V2 is meant to become a more meaningful blockchain research arena by introducing:

- realistic contract patterns
- stronger correctness tests
- invariant checks where practical
- structured benchmark output

The recommended V2 arena is:

- `gas_pack`

Recommended initial contract set:

- `TokenLedger`
- `RewardDistributor`
- `MerkleClaimer`

The goal is still to keep the research loop narrow. Even within a pack, each search pass should edit only one contract at a time.

## What V2 Currently Proves

Today the repo can honestly claim:

- a working V2 `gas_pack` harness exists
- `TokenLedger` has a real baseline and a completed keep-or-discard search pass
- the best kept `TokenLedger` result improved `median_gas` from `835526` to `813699`
- `TokenLedger` now has invariant-style validation in addition to correctness tests

That is stronger than V1, but it is still not the final research bar.

## What Would Count As Meaningful

A meaningful V2 result should show:

- gas improvements on realistic contract patterns
- invariant-preserving correctness
- fixed benchmark and validation surfaces during the search
- wins that beat obvious manual baselines
- evidence across more than one realistic contract pattern

Until then, the right description is:

- working V2 infrastructure with early promising results

not:

- proven autonomous blockchain research

## Current Cross-Contract Status

The repo now has validated baseline coverage across all three initial gas-pack contracts.

Using the current repository policy, the "obvious manual baseline" for each contract is the first validated readability-first implementation kept under the fixed benchmark and validation surface.

Current outcomes:

- `TokenLedger`: baseline `835526`, best kept `813699`, beat baseline
- `RewardDistributor`: baseline `887232`, best kept `862368`, beat baseline
- `MerkleClaimer`: baseline `250228`, best kept `250228`, flat so far

This means the repo now has stronger multi-contract evidence than before, but not yet broad success.

Why not yet:

- only two of the three current contract patterns have kept improvements
- explicit stronger manual comparators beyond the repository baselines are not yet defined
- more evidence is still needed before making a broader success claim

Current decision:

- broader success across realistic contract patterns is not yet justified

## Stronger Comparator Gap

The next bar is not just "beat the repo's first validated draft."

For each contract, the repo now treats the stronger comparison target as a plausible careful human gas-aware implementation:

- `TokenLedger`: human-specialized common mint and transfer paths
- `RewardDistributor`: human-specialized zero-accrual setup and claim-path accounting
- `MerkleClaimer`: human-specialized proof traversal and claim-state handling

The repo does not yet have direct benchmark evidence against those stronger comparators.

So the current wins should still be read as:

- beat the repository baseline

not yet:

- beat a stronger human gas-aware implementation

## Repository Anchors

- `scope.md`: source of truth for project direction
- `task.md`: active V2 checklist
- `program.md`: operating procedure for the blockchain arena
- `AGENTS.md`: contributor and agent working rules
- `context.md`: session continuity anchor when present

## Legacy Files

The repository still contains MLX-era files such as:

- `prepare.py`
- `train.py`
- `results.tsv`

Those files remain part of repository history, but they are not the active blockchain benchmark contract.

## License

MIT. See [LICENSE](LICENSE).

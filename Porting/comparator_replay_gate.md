# Migrated comparator replay: execution gate (not yet passed)

This is a work plan for the fork-only research branch. It is **not** a claim
that the comparator or independent kernel has been run successfully against
the migrated source.

## Verified starting point (2026-11-03)

- Lean toolchain: `leanprover/lean4:v4.36.0-rc2`.
- Full theorem spine, standard-axiom audit and 74-case positive convention
  hardening: successful in Actions run
  [41597080846](https://github.com/jesusvilela/mathlib4/actions/runs/41597080846)
  at `06ce00d771`.
- Static, source-pinned comparator audit: successful in
  [41597080957](https://github.com/jesusvilela/mathlib4/actions/runs/41597080957).
- Source-pinned historical comparator fixture configurations: eight JSON files,
  7 general-graph targets, 5 cycle targets and four invalid controls.
- **Not verified**: comparator execution, exported-proof compatibility,
  nanoda acceptance, sandbox enforcement, and four expected negative rejections
  on this toolchain.

## Compatibility boundary

The original cycle replay workflow in
`jesusvilela/connection_laplacian_lean@0b4ad40` pinned:
`leanprover/comparator@e3dcf30`,
`leanprover/lean4export@5a9a355`, a **Lean 4.11-specific exporter patch**,
`Zouuup/landrun@811cfff51ceaf3d9843708aa6d22e9b84ccac8b4`,
and `ammkrn/nanoda_lib@f67473ba5f9397266f89c7852082c9c914b5d219`.
Those pinned historical tools **must not be assumed compatible** with
Lean 4.36.0-rc2. In particular the old exporter patch is not a supported
4.36 migration by itself.

### Native comparator supersedes the historical portability plan

**Correction (2026-11-03):** Comparator was merged into Lean's Lake tooling
in **Lean 4.35**. The pinned Lean 4.36.0-rc2 source includes
`lake comparator` and `lake check` with toolchain-matched `leanexport`,
and a mandatory **Bubblewrap** sandbox unless explicitly disabled.
Consequently, **do not port or build the 4.11-specific external exporter
and comparator as the default migration route**. Use the native command
directly:

```bash
lake comparator --config=Hardening/config-cycle.json --json
```

The first native compatibility probe, CI workflow
`connection-laplacian-native-comparator-probe.yml`, is deliberately
**Lean-kernel-only**. A successful probe is not yet independent nanoda
evidence and does not discharge the four adversarial controls.
This is a pending run, not a claim of success.

Reference: Lean v4.36.0-rc2
`src/lake/Lake/CLI/Help.lean` (`helpComparator`) and the
Lean 4.35 release notes. The old standalone comparator README also
declares its own deprecation in favor of the Lake commands.

The historical exporter patch remains archived as provenance.
A compatibility failure is a failure of the replay infrastructure,
not a counterexample to the mathematics.

## Execution matrix

| Case | Configuration | Required result |
| --- | --- | --- |
| Graph positive (7 targets) | `Hardening/config-nanoda.json` | Comparator statement equality, allowed axioms, Lean default kernel and nanoda accept |
| Cycle positive (5 targets) | `Hardening/config-cycle-nanoda.json` | Same four positive checks |
| Graph statement tamper | `Hardening/config-negative1-tampered-challenge.json` | Nonzero exit **and** explicit statement mismatch |
| Graph local axiom | `Hardening/config-negative2-smuggled-axiom.json` | Nonzero exit **and** explicit forbidden-axiom diagnosis |
| Cycle phase tamper | `Hardening/config-cycle-negative-phase.json` | Nonzero exit **and** explicit statement mismatch |
| Cycle local axiom | `Hardening/config-cycle-negative-axiom.json` | Nonzero exit **and** explicit forbidden-axiom diagnosis |

A missing executable, failed import, timeout, OOM, failed exporter,
sandbox failure, or absent log **never counts as a correct negative rejection**.
Do not accept generic nonzero status for any of the four negative cases.

## Isolation and external kernel criteria

1. Run the native **Bubblewrap** sandbox on a compatible Linux host;
   record OS/kernel, the installed `bwrap` version, Lean toolchain and
   exact repository commit. Never pass `--inadvisably-no-sandbox`.
2. Before promoting trust, test sandbox-denied filesystem access separately
   and preserve its transcript; the native JSON report's
   `sandboxed: true` indicates that sandbox mode was enabled, but it
   does not substitute for an independently observed OS denial.
3. Record the Lean/Mathlib commits and names of all external checker binaries;
   the native exporter is the `leanexport` shipped with the same toolchain.
4. Require native comparator JSON reports showing successful kernel judgments
   in both positive runs. Require a separate, actually executed nanoda
   judgment (for example, via the existing `enable_nanoda` configurations)
   before claiming dual-kernel replay. Do not rely on legacy textual log
   markers without checking the newer structured report schema.
5. Archive all six JSON reports, diagnostics, independent sandbox probe,
   environment provenance and checksums as CI artifacts, including on
   failure. Keep credentials and tokens out of artifacts.
6. For negative controls distinguish exit status **1** (rejection) from
   **2** (unable to start), and inspect the structured report to reject
   unrelated build, sandbox, export, timeout or resource failures.

## Promotion rule

Promote this lane from *static configuration integrity passed* to
*independently replayed on Mathlib's current toolchain* **only when both
positive suites and all four diagnosed negative controls pass on the
same recorded commit, with confirmed nanoda execution and independently
demonstrated OS sandbox enforcement**. Keep this research gate separate from
`submission/signed-lap-foundation` and do not open an upstream PR on the
strength of this plan alone.

## 2026-11-04: first native comparison passed

At commit `8fae542bba0b6b47d5f948cd98bd4e371ec83f3c`,
[Actions run 41825483527](https://github.com/jesusvilela/mathlib4/actions/runs/41825483527)
completed successfully. The workflow ran the standard native
`lake comparator --config=Hardening/config-cycle.json` with exit status **0**
against the five cycle-spectrum challenge/solution targets, using the
migrated Lean 4.36.0-rc2 toolchain. Before invoking the comparator, it
executed a real Bubblewrap child and verified read-only host-file
isolation via a denied write. Its environment and logs are preserved in
the run's uploaded artifact.

**Promotion:** Native Lean-kernel challenge/solution comparison of five
cycle-spectrum targets is now verified on this migrated fork. This result
is **not** nanoda/dual-kernel acceptance, four negative rejection replays,
or independent source-to-mathematics validation. The challenge's graph-level
cycle-transfer theorem still has explicit matrix-reindexing hypotheses.

The next independent CI lane, `connection-laplacian-native-graph-comparator.yml`,
checks the seven general-graph statements using `Hardening/config.json`.
Its first run is [41832221841](https://github.com/jesusvilela/mathlib4/actions/runs/41832221841);
no verdict was available when this entry was written.

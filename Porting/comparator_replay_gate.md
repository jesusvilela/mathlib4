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

Before constructing an expensive full replay, establish and record a
4.36-compatible exporter and comparator revision and build both from
recorded SHAs. Do not silently downgrade the Mathlib port or import the
historical exporter patch as if it were current. A compatibility failure is
a failure of the replay infrastructure, not of the mathematics.

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

1. Run the real landlock sandbox on a host where enforcement is supported;
   record OS/kernel version and `landrun` revision.
2. Before trusting positive runs, execute a **separate forbidden read/write
   probe** and preserve the denial transcript. A selected binary's presence,
   or a `COMPARATOR_LANDRUN` variable, is not an enforcement test.
3. Record the precise Lean, Mathlib, comparator, exporter, landrun and
   nanoda versions and revisions; fail closed when any are missing.
4. Check for actual `Lean default kernel accepts the solution`,
   `nanoda kernel accepts the solution` and `Your solution is okay!`
   markers separately in *each* positive replay log. Audit the exported
   kernel input and its size.
5. Archive all six comparator logs, the independent sandbox probe,
   environment provenance, full tool SHAs and checksums as an Actions
   artifact (including on failure). Exclude credentials and tokens.

## Promotion rule

Promote this lane from *static configuration integrity passed* to
*independently replayed on Mathlib's current toolchain* **only when both
positive suites and all four diagnosed negative controls pass on the
same recorded commit, with confirmed nanoda execution and independently
demonstrated OS sandbox enforcement**. Keep this research gate separate from
`submission/signed-lap-foundation` and do not open an upstream PR on the
strength of this plan alone.

# Connection Laplacian — full Lean migration lane

This branch is an **experimental full-port workspace**, separate from the
[clean, upstream-aligned unified signed-Laplacian PR candidate](https://github.com/jesusvilela/mathlib4/tree/submission/signed-laplacian-unified-current).
The earlier foundation-only candidate is retained as an optional maintainer-requested split.

Source: [jesusvilela/connection_laplacian_lean](https://github.com/jesusvilela/connection_laplacian_lean)
at commit `0b4ad40a7dd26d924bd44096eaa5291c3882a67b`.
The source toolchain was Lean `v4.11.0`; this Mathlib fork uses its own,
newer toolchain. All 36 source Lean files were staged unchanged. Git blob hashes
were compared against the source repository: **36/36 identical at staging**.

* 19 theorem-spine files: root `ConnectionLaplacian.lean` and 18
  `ConnectionLaplacian/*.lean` files (including `AxiomAudit.lean`).
* 16 `Hardening/**/*.lean` files, including convention batteries and
  intentionally failing negative controls.
* 1 archived `findings/**/axiom_check.lean` file.

The original source remains the authority for historical proof and review
artifacts. Copying files **does not imply** that they compile or satisfy
Mathlib standards on the newer toolchain.

## Two independent destinations

1. **Full-port branch (here):** retain every theorem and dependent proof;
   modernize imports, adapt APIs, audit statement correspondence, compile and
   independently verify the positive proof spine. Run negative hardening
   fixtures *as expected-failure tests*, not as ordinary modules.
2. **Upstream Mathlib:** propose a small reusable 360-line module with 19
   public theorems from `submission/signed-laplacian-unified-current` plus one
   import, preserving `submission/signed-lap-foundation` as a fallback.
   The clean proposal passed [upstream-base verification](https://github.com/jesusvilela/mathlib4/actions/runs/41879159967).
   No upstream pull request is open.

## Verification gates

| Gate | Status |
| --- | --- |
| Every original Lean source accounted for | **Source mirrored** (36/36 SHA-equal at staging) |
| `ConnectionLaplacian.Basic` compiles on fork toolchain | **Passed** after explicit real/matrix imports and current dot-product name; [CI](https://github.com/jesusvilela/mathlib4/actions/runs/41455484200) |
| `ConnectionLaplacian.KernelDimension` compiles on fork toolchain | **Passed** after dimensional API and matrix-entry proof migration; [full-spine probe](https://github.com/jesusvilela/mathlib4/actions/runs/41456475394) then reached `CycleSpectrum` |
| `ConnectionLaplacian.CycleSpectrum` compiles | **Passed** with explicit trigonometric identities and parity proof updates; [CI](https://github.com/jesusvilela/mathlib4/actions/runs/41456921261) |
| `ConnectionLaplacian.L5_Cover` and `L6_Cohomology` compile | **Passed** after modern graph-relation, cover type and decidability upgrades; [CI](https://github.com/jesusvilela/mathlib4/actions/runs/41458728611) |
| Complete original theorem spine compiles | **Passed:** all 17 modules and the root/audit files on the newer toolchain; [CI run 41474652642](https://github.com/jesusvilela/mathlib4/actions/runs/41474652642) |
| Statement-by-statement mathematical correspondence | **Textual audit complete:** 189 theorem/lemma headers match the pinned source after the documented `finrank` spelling normalization; 56 definition/structure headers have one API adaptation (`CoverV`: `def` → `abbrev`). Elaborated-type and definitional-equivalence checks remain open. |
| Transitive axiom and independent checker audit | **Research spine:** 25/25 selected declarations with standard axioms. **Proposed Mathlib module:** all 19 public declarations passed the exact standard-axiom allowlist and six checker modes [on upstream-current CI](https://github.com/jesusvilela/mathlib4/actions/runs/41879159967). The separate research bridge passed [its own six-checker replay](https://github.com/jesusvilela/mathlib4/actions/runs/41878884925). |
| Hardening battery and negative-test isolation | **Positive Lean suite:** ten modules, 74 graph cases plus monolith [41863994070](https://github.com/jesusvilela/mathlib4/actions/runs/41863994070). **Research comparator:** 7 graph + 5 cycle positives with paranoid checks [41859926384](https://github.com/jesusvilela/mathlib4/actions/runs/41859926384); four expected-rejection controls [41859850561](https://github.com/jesusvilela/mathlib4/actions/runs/41859850561). An earlier source-pinned cycle-axiom fixture rejected for statement mismatch; a separate native-only replacement demonstrated explicit illegal-axiom rejection. |
| Community review and upstream acceptance | **Pending** |

The [dependency-aware compilation script](check_connection_spine.sh) now
compiles the full 19-file theorem spine (17 modules, root and axiom audit)
with cached `.olean` outputs. The [verified run](https://github.com/jesusvilela/mathlib4/actions/runs/41474652642)
established **25/25 standard-axiom-only declarations**, not an independent
comparator replay. Every original Lean theorem file remains accounted for;
a textual audit matched 189 theorem/lemma headers; independent elaborated-type correspondence and definition-body equivalence are still open.

The standalone [positive hardening probe](check_hardening_positive.sh) now
separately tests solution aliases and bounded convention examples. Legacy
challenge files intentionally contain `sorry` and MUST NOT be promoted as
proved results merely because they elaborate. The newer-toolchain comparator, paranoid-checker and negative-control
replays were later executed successfully in dedicated jobs; see the
verification table above. Those checks are distinct from this positive
fixture compilation.
Preserve the original names and statements unless each change is
mathematically justified and documented. Do not erase the historically
corrected general-graph balance invariant: total negative-edge parity is
**not** equivalent to component balance. Nor should a conditional cycle
matrix-reindexing theorem be promoted to an unconditional statement.

## 2026-11-03: positive hardening migration passed

At commit `a4405860161c2b080451c4026727b8fbd15f1876`, the fork-only
[positive hardening workflow](https://github.com/jesusvilela/mathlib4/actions/runs/41593486656)
passed the full theorem-spine and standard-axiom audit, then compiled **all ten**
selected hardening modules: Compat, Solution, CycleSolution, BatteryPrelude,
ConventionAnchor, BatteryA, BatteryB, BatteryC, BatteryD, and ConventionBattery.
The four shards cover **74 graph cases** (19 + 19 + 18 + 18); the 74-case
monolith independently compiles the corresponding statements. A source
comparison found the original edge/wrap sets and the 148 literal expected
signed/ordinary matrix values unchanged. Successful Lean compilation is
an evidence claim about the encoded statements, not a third-party review.

## Comparator portability: distinct evidence gate

The comparator challenge and solution files and all four intentionally
negative fixtures are source-pinned to
`jesusvilela/connection_laplacian_lean@0b4ad40a7dd26d924bd44096eaa5291c3882a67b`.
The historical comparator JSON configurations and source checker are
preserved byte-for-byte; see `comparator_source_hashes.json` and
`audit_comparator_port.py`. The dedicated comparator-static workflow
checks provenance, coverage, positive/negative configuration and absence
of untrusted imports into the production Lean spine.

**That workflow is static.** It does not itself build or run comparator,
nanoda, lean4export, or sandboxed independent-kernel checks. Separate later
workflows established the seven-graph/five-cycle positive replay
([41859926384](https://github.com/jesusvilela/mathlib4/actions/runs/41859926384))
and four negative controls
([41859850561](https://github.com/jesusvilela/mathlib4/actions/runs/41859850561)).
The research-to-Mathlib matrix identity was also checked by all six named
checker modes [in run 41878884925](https://github.com/jesusvilela/mathlib4/actions/runs/41878884925).
The source-pinned *historical* cycle-axiom control initially rejected for
statement mismatch; the new native-only fixture explicitly tests illicit
axioms. Do not equate either negative test with universal adversarial
assurance. Full 189-theorem source-versus-port elaborated-type equivalence
and the `CoverV` def/abbrev reducibility audit remain open.

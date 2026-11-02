# Connection Laplacian — full Lean migration lane

This branch is an **experimental full-port workspace**, separate from the
small [verified first signed-Laplacian PR candidate](https://github.com/jesusvilela/mathlib4/tree/submission/signed-lap-foundation).

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
2. **Upstream Mathlib:** submit small reusable modules with stable public APIs.
   The small foundation-only candidate is staged at `submission/signed-lap-foundation`
   and has [successful CI](https://github.com/jesusvilela/mathlib4/actions/runs/41448667166).
   The fuller signed-Laplacian proof module remains separate.
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
| Statement-by-statement mathematical correspondence | **Pending** |
| Transitive axiom and independent checker audit | **Transitive axiom audit passed:** 25/25 declarations, only `Classical.choice`, `Quot.sound`, `propext`; additional independent rechecking pending |
| Hardening battery and negative-test isolation | **Under verification:** separately compiled positive proof aliases and finite convention batteries; historical comparator negative controls remain out of the trusted spine |
| Community review and upstream acceptance | **Pending** |

The [dependency-aware compilation script](check_connection_spine.sh) now
compiles the full 19-file theorem spine (17 modules, root and axiom audit)
with cached `.olean` outputs. The [verified run](https://github.com/jesusvilela/mathlib4/actions/runs/41474652642)
established **25/25 standard-axiom-only declarations**, not an independent
comparator replay. Every original Lean theorem file remains accounted for;
a complete *statement-by-statement correspondence* review is still open.

The standalone [positive hardening probe](check_hardening_positive.sh) now
separately tests solution aliases and bounded convention examples. Legacy
challenge files intentionally contain `sorry` and MUST NOT be promoted as
proved results merely because they elaborate. New-toolchain comparator,
nanoda, and negative-control replay remains an independent gate.
Preserve the original names and statements unless each change is
mathematically justified and documented. Do not erase the historically
corrected general-graph balance invariant: total negative-edge parity is
**not** equivalent to component balance. Nor should a conditional cycle
matrix-reindexing theorem be promoted to an unconditional statement.

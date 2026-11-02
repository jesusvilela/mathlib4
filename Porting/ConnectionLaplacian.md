# Connection Laplacian — full Lean migration lane

This branch is an **experimental full-port workspace**, separate from the
small [upstream-ready signed-Laplacian patch](https://github.com/jesusvilela/mathlib4/tree/submission/signed-graph-laplacian).

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
   The independent signed-Laplacian module, already kernel-checked and
   Mathlib-linted, is staged on `submission/signed-graph-laplacian`.
   No upstream pull request is open.

## Verification gates

| Gate | Status |
| --- | --- |
| Every original Lean source accounted for | **Source mirrored** (36/36 SHA-equal at staging) |
| `ConnectionLaplacian.Basic` compiles on fork toolchain | **Pending** |
| Complete original theorem spine compiles | **Pending** |
| Statement-by-statement mathematical correspondence | **Pending** |
| Transitive axiom and independent checker audit | **Pending** |
| Hardening battery and negative-test isolation | **Pending** |
| Community review and upstream acceptance | **Pending** |

The immediate probe is `lake env lean ConnectionLaplacian/Basic.lean`.
Preserve the original names and statements unless each change is
mathematically justified and documented. Do not erase the historically
corrected general-graph balance invariant: total negative-edge parity is
**not** equivalent to component balance. Nor should a conditional cycle
matrix-reindexing theorem be promoted to an unconditional statement.

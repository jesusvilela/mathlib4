# Proposed single Mathlib PR — draft, not submitted

**Suggested title:** `feat(Combinatorics/SimpleGraph): define signed graph Laplacians and their energy`

**Provisional PR head:** `jesusvilela:submission/signed-laplacian-unified-current`
**Target:** `leanprover-community/mathlib4:master`

The following body is prepared for human review and should be copied only
after the current-upstream compatibility gate is green. The older foundation
and follow-on branches remain optional split points if maintainers request them.

---

## Summary

This PR adds signed adjacency and Laplacian matrices for finite simple
graphs equipped with a Boolean edge labeling (`SimpleGraph.EdgeLabeling Bool`).

An edge labeled `true` has adjacency weight `-1`; an edge labeled
`false` has weight `+1`. Nonedges have weight zero. The signed
Laplacian is `D - Aₛ`, specializing to the usual Laplacian when all
edges are positive and to the signless Laplacian when all are negative.

Over `ℝ`, the module also proves symmetry and Hermitian structure, the
edgewise quadratic-form identity

```text
xᵀ Lₛ x = (1/2) ∑ᵤ ∑ᵥ (if G.Adj u v then (x u - Aₛ u v * x v)^2 else 0),
```

positive semidefiniteness for arbitrary signings, and two equivalent
characterizations of the zero-energy / kernel vectors: a vector is in
the kernel exactly when its values agree across each edge according
to that edge's sign.

The addition uses Mathlib's existing `EdgeLabeling`, `degMatrix`,
`adjMatrix`, and `Matrix.PosSemidef` APIs.

## Scope

The proposed upstream change consists of **two files**:
`Mathlib/Combinatorics/SimpleGraph/SignedLapMatrix.lean` and its single
import in `Mathlib.lean`. The new module defines two matrices and
provides 19 public theorem declarations.

It does *not* add the historical connection-Laplacian research
development, spectral factorizations, cover constructions, custom
proof-verification pipelines, Python tests, or workflow files to
upstream Mathlib. Those remain in the author's separate research
and verification branches.

## Checks already performed against the frozen source

- The 19-theorem module compiled, passed Mathlib linting and an exact
  transitive standard-axiom audit: [verification CI](https://github.com/jesusvilela/mathlib4/actions/runs/41861086119).
- All 19 selected theorem exports were accepted by Lean's paranoid
  checker configurations (including nanoda, lean4lean, con-leche and
  con-ron): [verification CI](https://github.com/jesusvilela/mathlib4/actions/runs/41872683913).
- A research-only theorem proves equality of this library's signed
  operator with the original Möbius-sector signed Laplacian for the
  corresponding Boolean edge signs:
  [bridge proof CI](https://github.com/jesusvilela/mathlib4/actions/runs/41870656627).
- Exact finite-graph controls cover all 761 signed graphs with up to
  four labeled vertices, including gauge transformations and kernel
  tests: [reference CI](https://github.com/jesusvilela/mathlib4/actions/runs/41864971253).

The current-upstream source migration preserves the same 360-line
library blob, `70af2c839ff1e1274035de4d89a2385cf2cc7d3e`,
on Mathlib's 2026-11-04 upstream base `a84939a`.
Its fresh compile/lint/import-index/axiom/six-kernel workflow is
[upstream compatibility CI](https://github.com/jesusvilela/mathlib4/actions/runs/41879159967).
**That last result was pending when this draft was written.**
Do not call it passed until the exact CI run finishes successfully.

All of these checks concern proof correctness under the encoded
statements. They do not substitute for maintainers' independent
review of naming, mathematical generality, style and utility.

## Maintainer guidance welcome

The goal is one coherent signed-Laplacian module, rather than
separate definition-only and PSD/kernel PRs. If reviewers prefer
a smaller initial API, the foundation and extension commits remain
available and can be split without changing the resulting theorems.

---

### Author's pre-submission gate (not part of PR body)

- [ ] Current-upstream test completed successfully with strict 19-name
  axiom allowlist, `mk_all --check`, and six paranoid checker modes.
- [ ] The clean upstream-base submission branch's diff remains exactly
  two files, no proof harness included.
- [ ] All external evidence links verified and reviewed for their actual
  theorem target and source commit.
- [ ] Review wording and AI-assistance attribution for transparency
  without claiming that checkers verify mathematical intention.
- [ ] One PR only; do not open a foundation PR unless maintainers ask.

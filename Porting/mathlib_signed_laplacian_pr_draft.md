> **ARCHIVAL INTERNAL MODEL-WRITTEN DRAFT — DO NOT COPY INTO A MATHLIB PR.**
> The community's [2026 AI contribution guidelines](https://mathlib.org/contribute/index.html#use-of-ai)
> prohibit using an LLM to write GitHub and Zulip comments, require an
> accurate disclosure of AI tools and their role, and require the human
> contributor to understand and independently justify all AI-written
> material. This draft is usable for **private fact-checking only**.
> The eventual public PR description must be written by the human author
> in their own words after reviewing
> [the human ownership gate](./mathlib_author_ownership_gate.md).
> Machine CI being green does not establish that gate.
>
# Proposed single Mathlib PR — draft, not submitted

**Suggested title:** `feat(Combinatorics/SimpleGraph): define signed graph Laplacians and their energy`

**Provisional PR head:** `jesusvilela:submission/signed-laplacian-unified-current`
**Target:** `leanprover-community/mathlib4:master`

The current-upstream compatibility gate is now green. This is a **review-ready
draft, not an authorized or submitted PR**; the author still needs to read
and approve its text, including the AI-assistance disclosure. The older
foundation and follow-on branches remain fallback split points.

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
  The exact theorem was subsequently exported and accepted by six configured
  independent checker modes with verified sandbox denial:
  [direct bridge replay 41878884925](https://github.com/jesusvilela/mathlib4/actions/runs/41878884925).
- Exact finite-graph controls cover all 761 signed graphs with up to
  four labeled vertices, including gauge transformations and kernel
  tests: [reference CI](https://github.com/jesusvilela/mathlib4/actions/runs/41864971253).

The current-upstream source migration preserves the same 360-line
library blob, `70af2c839ff1e1274035de4d89a2385cf2cc7d3e`,
on Mathlib's 2026-11-04 upstream base `a84939a`.
Its fresh compile/lint/import-index/axiom/six-kernel workflow is
[upstream compatibility CI](https://github.com/jesusvilela/mathlib4/actions/runs/41879159967).
**Result verified on 4 November 2026: passed.** The run completed successfully at `fe1d33c00c2ff739c9f0c5b55c181d9826fc776c`, checking the unchanged 19-theorem source against upstream `a84939a26903163e1b98ee002bc94e9563e75c12`. The job reports successful compilation, linting, `mk_all --check`, the exact standard-axiom allowlist, a source-selected 19-declaration export, and acceptance by all six configured checker modes (Lean paranoid, lean4lean, nanoda, con-leche, con-ron, Lean default).

All of these checks concern proof correctness under the encoded
statements. They do not substitute for maintainers' independent
review of naming, mathematical generality, style and utility.

**AI provenance note (internal; not to paste):** An AI assistant generated or substantially modified Lean code and proof tactics, portability changes, CI configurations, test harnesses and explanatory text during this collaboration. These are not merely autocomplete edits. The author needs to determine the provenance of any further external AI tools used, independently understand every proposed declaration, obtain subject-expert supervision where required, and describe the specifics without assistance in the eventual public PR. Per Mathlib's policy, substantial LLM-generated code must be labeled `LLM-generated`.

## Maintainer guidance welcome

The goal is one coherent signed-Laplacian module, rather than
separate definition-only and PSD/kernel PRs. If reviewers prefer
a smaller initial API, the foundation and extension commits remain
available and can be split without changing the resulting theorems.

---

### Author's pre-submission gate (not part of PR body)

- [x] Current-upstream test completed successfully with strict 19-name
  axiom allowlist, `mk_all --check`, and six checker modes ([run 41879159967](https://github.com/jesusvilela/mathlib4/actions/runs/41879159967)).
- [x] The clean upstream-base submission branch's diff remains exactly
  two files, no proof harness included (compared to `a84939a` on 4 November 2026).
- [x] The five linked CI runs were checked as successful and their stated
  targets distinguished; the current-upstream run checks source blob `70af2c83`.
- [ ] Human author to independently write the entire public PR description in their own words; no model-authored GitHub/Zulip comments.\n- [ ] Human ownership gate completed and Lean subject-expert supervision documented as appropriate; proof checkers cannot verify human mathematical understanding.\n- [ ] Accurate, detailed AI-generation provenance and `LLM-generated` label prepared for the real PR.
- [x] Exact source-to-research operator bridge accepted by all six named
  checker modes ([run 41878884925](https://github.com/jesusvilela/mathlib4/actions/runs/41878884925)); this remains research-only and outside the PR diff.
- [x] Added a [human mathematical orientation note](./signed_laplacian_human_review.md)
  separating the 19 public API theorems from the historical research.
- [x] One PR only; do not open a foundation PR unless maintainers ask. No upstream PR has been opened.

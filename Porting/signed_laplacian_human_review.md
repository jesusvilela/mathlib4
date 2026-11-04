# Signed graph Laplacians: human review map

> Research-only orientation note, **not part of the proposed upstream Mathlib PR**.
> Evidence snapshot: 4 November 2026, scoped to the exact commits and runs below.

## What is being added?

Take a finite, undirected simple graph `G` and label each edge by a Boolean
`wrap`. In the proposed Mathlib convention,

- `false` means a **positive** edge, with signed adjacency entry `+1`;
- `true` means a **negative** edge, with signed adjacency entry `-1`;
- a nonedge has adjacency entry `0`.

If `Aσ` is that signed adjacency matrix and `D` is the **ordinary unsigned**
vertex-degree matrix, the signed Laplacian is `Lσ = D - Aσ`.
In particular, `Lσ(u,u) = degree(u)`; a negative sign never subtracts from
the degree. All-positive signs recover `G.lapMatrix ℝ`; all-negative signs
give `D + A`, the signless Laplacian.

The submitted API handles real matrices and Boolean signs `±1`; it does not
assert results for weighted graphs, directed graphs, or arbitrary unitary
connections.

## Why the quadratic-form theorem matters

For every real vertex function `x : V → ℝ`, the module proves

```text
xᵀ Lσ x = 1/2 Σ_u Σ_v [if u ~ v then (x(u) - Aσ(u,v) * x(v))² else 0].
```

The double sum ranges over **ordered** vertex pairs; each undirected edge
appears twice, hence `1/2`. Equivalently, summing once over undirected edges,
the energy is `Σ_{uv ∈ E} (x(u) - σ_uv x(v))²`.

That immediately explains two public Lean conclusions:

1. `Lσ` is positive semidefinite, for **every** signing.
2. Its kernel consists exactly of vertex functions compatible with every
   signed edge, i.e. `x(u) = σ_uv x(v)` whenever `u ~ v`.

This is stronger than saying that `Lσ` is symmetric, and it distinguishes
the signed case from ordinary connected-graph constants. The module proves
these results, not just examples of them.

## One triangle illustrates the obstruction

Index vertices by `0,1,2` with all three edges present.

**All positive:** `Aσ(u,v) = +1` for every edge.

```text
L+ = [ 2 -1 -1 ; -1 2 -1 ; -1 -1 2 ].
spectrum: {0,3,3}; constant vector (1,1,1) is in the kernel.
```

**Exactly one negative edge** (between vertices `0` and `1`):

```text
L- = [ 2  1 -1 ;  1 2 -1 ; -1 -1 2 ].
spectrum: {1,1,4}; the kernel is trivial.
```

Why? The two positive edges require agreement with vertex `2`, while the
negative edge requires vertices `0` and `1` to have opposite values.
Only zero can satisfy all three conditions. More generally, transporting
a nonzero value around a cycle is consistent only when the product of its
edge signs is `+1`. The full component-balance/kernel-dimension theory
belongs to the broader research development; it is **not** a theorem newly
submitted in this two-file upstream candidate.

## Typed bridge to the original research

The research type `ConnGraph` stores negative-edge information as a
predicate `G.wrap : G.graph.edgeSet → Prop`. The research-only
`wrapEdgeLabeling` converts that predicate to Mathlib's Boolean
`EdgeLabeling` with `decide`. The theorem in
`Porting/MathlibBridge.lean` is an equality of **actual matrices**:

```lean
theorem signedLaplacianMobius_eq_signedLapMatrix (G : ConnGraph) :
    G.signedLaplacianMobius =
      G.graph.signedLapMatrix G.wrapEdgeLabeling
```

This does not identify all of the original research's spectral, cover,
holonomy or cohomological theorems with the proposed Mathlib API; it
identifies the signed operator under this exact signing conversion.

## Evidence: what was actually checked?

| Target | Evidence | Limit |
| --- | --- | --- |
| Upstream-ready 19 public Lean theorems and definitions | [upstream-current CI 41879159967](https://github.com/jesusvilela/mathlib4/actions/runs/41879159967): build, lint, `mk_all --check`, exact three-axiom allowlist, direct six-checker acceptance | Checks encoded theorems, not usefulness or originality |
| Research-to-Mathlib operator equality | [bridge CI 41878884925](https://github.com/jesusvilela/mathlib4/actions/runs/41878884925): Lean elaboration, sandbox write-denial, and direct acceptance by six checkers | Research-only theorem; **not** in submitted PR |
| Finite-graph mathematical reference | [oracle CI 41864971253](https://github.com/jesusvilela/mathlib4/actions/runs/41864971253): all **761** absent/positive/negative edge assignments on **0–4 labeled vertices**, exact rational arithmetic | Finite reference test, not a kernel proof |
| Historical research comparator positives and negatives | [positive paranoid CI 41859926384](https://github.com/jesusvilela/mathlib4/actions/runs/41859926384) and [four negative controls CI 41859850561](https://github.com/jesusvilela/mathlib4/actions/runs/41859850561) | Different theorem set; original cycle-axiom fixture had an earlier mismatched-statement rejection |

The exact proposed module blob is
`70af2c839ff1e1274035de4d89a2385cf2cc7d3e` (360 lines).
The clean branch `submission/signed-laplacian-unified-current` is
based on upstream Mathlib `a84939a26903163e1b98ee002bc94e9563e75c12`,
with exactly two changed files: this module and one `Mathlib.lean` import.
The **historical full-source elaborated-type correspondence** and the
`CoverV` `def`→`abbrev` reducibility review remain separate open research
audits; successful Mathlib candidate checking does not close them.

## Human review questions before an upstream PR

Does Mathlib want Boolean edge labels and real matrices as this initial API?
Are names/module placement and the `signless` specializations desirable in
this location? Is the quadratic energy identity most useful expressed over
ordered pairs, or should a later API offer an unoriented-edge sum? Should the
single 360-line module be split for review? These are maintainer judgments.

The author still needs to review the PR body and AI-assistance disclosure.
**No upstream PR has been opened.** The submission and fallback branches
must remain untouched until that review is complete.

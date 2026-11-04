# Human ownership gate before a signed-Laplacian Mathlib PR

> **Internal research and learning checklist; not a GitHub/Zulip comment or a draft to paste.**
>
> Scope: `submission/signed-laplacian-unified-current`, two-file diff,
> source blob `70af2c839ff1e1274035de4d89a2385cf2cc7d3e`,
> upstream base `a84939a26903163e1b98ee002bc94e9563e75c12`,
> toolchain Lean 4.36.0-rc2. Prepared 2026-11-04.

## Why this gate exists

Mathlib's official 2026 contribution guidelines
(https://mathlib.org/contribute/index.html#use-of-ai) require the human
contributor to understand *all* AI-written code and to justify design
choices independently. They forbid using an LLM to **write GitHub/Zulip
comments** and require disclosing precisely which AI tools were used and
how. Substantial LLM-generated Lean requires the `LLM-generated` label.
They warn that AI-generated code without expert supervision may fall below
Mathlib's quality bar.

Those are independent requirements from machine proof checking. **Do not
open or comment on an upstream PR by copying model-written text.** The
older PR draft in this repository is archival internal analysis only.
The human author should write every public description and reply in
their own words. There is no evidence in the CI logs that a human expert
has performed this review, and no CI run can establish that competence.

## The exact mathematical object to reconstruct without AI

For a finite simple undirected graph `G`, Boolean edge signing
`wrap : G.EdgeLabeling Bool`, and `u,v : V`, use the convention

```
sigma(u,v) = -1 if wrap.get u v h = true, +1 otherwise (on an edge)
A_sigma(u,v) = sigma(u,v) for edges, 0 for nonedges
D(u,u) = degree_G(u), D(u,v)=0 if u != v
L_sigma = D - A_sigma
```

The negative sign changes the **off-diagonal**, never the diagonal
degree. A `true` edge corresponds to a wrap in the original research
operator. The signed matrix is real, not general complex/unitary/weighted.

### Independent reconstruction exercises (not a quiz to answer by pasting AI)

1. Derive `L_sigma(u,u)=deg_G(u)` from irreflexivity. Check whether this
   remains true for an isolated vertex and the empty graph.
2. Prove that `A_sigma` is symmetric using the fact that `EdgeLabeling`
   labels unoriented `edgeSet` elements, and then show the real Laplacian
   is Hermitian.
3. Derive the **ordered-pair** identity
   `xᵀ L_sigma x = (1/2) Σ_u Σ_v 1_{u~v}(x_u − sigma(u,v)x_v)^2`.
   Account explicitly for the factor `1/2` and for `sigma^2=1`;
   independently verify all-negative signs give the signless form.
4. From that identity, prove positive semidefiniteness over `ℝ`
   without relying on the compiled Lean proof.
5. Explain why zero energy forces **every** edgewise square to vanish
   (not merely their sum), and why the PSD lemma upgrades
   `xᵀLx=0` to `Lx=0`.
6. On an all-positive triangle, compute `L` and its spectrum
   `{0,3,3}`. Negate exactly one edge and compute the spectrum
   `{1,1,4}`; explain why the kernel disappears.
7. Demonstrate gauge switching by a vertex-sign map
   `t:V→{−1,+1}`: `L_(sigma')=T L_sigma T`, where
   `sigma'(u,v)=t_u sigma(u,v)t_v`. Distinguish this mathematically
   useful *reference invariant* from what the 19 submitted Lean
   theorems actually assert (gauge equivalence is not in that PR).
8. Explain why the original `ConnGraph.wrap : G.graph.edgeSet→Prop`
   converts exactly into `G.graph.EdgeLabeling Bool` using
   `decide`, and reproduce the diagonal/edge/nonedge proof of the
   research-only bridge identity.
9. For each of the 19 public declarations, locate its exact Lean
   signature and justify why its hypotheses are sufficient. In
   particular explain why `PosSemidef` does **not** imply trivial
   kernel for an all-positive connected graph.
10. Explain the decision to start with `ℝ` and Boolean signs instead
    of an arbitrary star ring or weighted graph; discuss whether a
    subsequent generalization belongs in a different Mathlib layer.

## Lean construction and maintenance checks

The author should be able to explain these code-specific decisions,
without treating an axiom-clean CI log as a substitute for understanding:

- Why `SimpleGraph.EdgeLabeling.get_comm` is relevant to an
  unoriented-edge proof, and why an arbitrary `V→V→Bool` sign matrix
  would need a separate symmetry assumption.
- Why some declarations use `omit [Fintype V] [DecidableEq V]`, how
  `[DecidableRel G.Adj]` is used, and what cannot be inferred from
  a mathematical `Decidable` instance.
- How the private lemma `signedLapMatrix_quadForm_raw` is used in the
  public energy identity and where the finite sums are rearranged.
- Why `signedLapMatrix_mulVec_eq_zero_iff_forall_adj` uses the PSD
  zero-quadratic-form equivalence rather than being an immediate
  `simp` consequence.
- What changes could break the API under a future Mathlib update, and
  how to rerun `mk_all --check`, `lake exe runLinter`, exact
  axiom allowlisting, and independent kernel verification.

## Disclosure and release decision (human-only)

**Provenance facts to review and describe accurately in the author's own
words:** the mathematical direction and desired contribution came from a
human-led research program; ChatGPT/other AI assistance performed substantial
Lean theorem construction, proof migration, CI design, independent-checker
orchestration, and documentation drafts. The GitHub Actions checks certify
encoded proof artifacts, not human expertise, mathematical novelty or
maintainer acceptance. The original source and AI-generated portions should
be truthfully identified; do not describe this as mere autocomplete.

Before opening an upstream PR:

- The human author has personally reconstructed/explained the ten
  mathematical prompts and Lean decisions, and understands the API
  without model assistance.
- A real Lean/mathlib subject expert has reviewed the design where
  needed; the check outcome or reviewer's comments are recorded
  truthfully, not assumed.
- The author has read the community guidelines and will write the
  GitHub PR description and discussion **themselves**, including an
  accurate AI-use statement. The `LLM-generated` label is applied
  through the appropriate permitted mechanism if submitting substantial
  LLM-written code.
- The final upstream two-file diff, target commit, and CI results are
  checked again if the base or code changes.
- The original foundation and proof-bearing branches remain available
  if maintainers request a smaller first contribution.

**Decision:** the mechanical proof gate is green at the recorded
revisions. The **human readiness and community review gates remain open**.
Do not infer their completion from this document.

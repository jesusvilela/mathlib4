# One-PR strategy: unified signed Laplacian and comprehensive verification

Decision recorded 2026-11-04. This document governs **submission scope**;
it is not a claim of Mathlib acceptance or comprehensive verification.

## Branches and their roles

| Branch | Role | Preserve? |
| --- | --- | --- |
| `submission/signed-laplacian-unified` | **Single proposed upstream PR candidate**: signed adjacency, signed Laplacian, symmetry, Hermitian, ordinary/signless specializations, energy/PSD and edgewise kernel characterizations in `Mathlib/Combinatorics/SimpleGraph/SignedLapMatrix.lean` | Yes |
| `submission/signed-lap-foundation` | Minimum definitions-only fallback if Mathlib requests a split | Yes |
| `submission/signed-graph-laplacian` | Original proof-bearing extension fallback | Yes |
| `verification/signed-lap-foundation` | Historical foundation CI evidence and independent setup | Yes |
| `research/connection-laplacian-full-port` | Original broader connection-Laplacian research corpus; complete theorem spine, comparator transcript, negative tests, toolchain port and evidence ledger | Yes |

Do **not** make a Mathlib PR from `research/connection-laplacian-full-port`
or copy its `Hardening/`, `Porting/`, or experiments into the upstream diff.
The **current unified candidate contains the reusable signed-graph module**,
not all 19 original connection-Laplacian spine files. Broader formalization
would require explicit scope review and Mathlib-ready module adaptation.
One PR is the default preference, subject to maintainer feedback about size,
reviewability, naming and module location.

The unified candidate was created from the complete follow-on branch.
It has its own fork-only
`.github/workflows/signed-lap-unified-ci.yml` verification workflow.
Before an upstream PR, keep CI evidence but **remove this fork-only workflow
from the PR diff**, unless maintainers ask for it. In the final upstream diff,
prefer changes only in Mathlib's library sources and imports.

## Comprehensive verification as a gate

1. **Source and type fidelity:** compare each submitted declaration's
   elaborated theorem type and definition body against the intended
   mathematics and original source; formally enumerate conditional
   hypotheses. Do not promote the cycle-to-graph reindexing theorem to
   an unconditional classification.
2. **Target fork build:** compile, lint and audit all 19 public theorem
   declarations in the unified signed-Laplacian module with current
   toolchain, with only standard axioms; verify the import from Mathlib.
3. **Research-spine build:** preserve previously demonstrated full
   19-file connection-Laplacian spine build, 25 standard-axiom selected
   declarations and the historical 74-graph convention battery. These
   establish distinct targets and cannot be substituted for the new
   upstream signed module.
4. **Positive comparator:** 12/12 challenge/solution targets already
   accepted by the Lean native comparator: 5 cycle, 7 graph, in separate
   runs with demonstrated sandbox denial.
5. **Adversarial comparator:** all four negative tests must reject for
   their **intended** reason; three previously passed. The historical
   fourth (cycle smuggled axiom) was rejected for statement mismatch,
   not forbidden axiom. Preserve that failure. A new native-only
   elaboration-aligned fixture is being tested separately.
6. **Independent kernel:** require actual `lake comparator --paranoid`
   successful replay on both positive suites, with logs proving that
   bundled independent checkers actually executed. A missing kernel,
   sandbox failure, or timeout is not a theorem refutation, and cannot
   count as a pass.
7. **Human review:** verify theorem usefulness, API style, naming and
   scope with Mathlib maintainers. Independent kernels do not supply
   a human semantic review.

**No PR opening or merging solely on this evidence ledger.**
The candidate must be verified at the exact commit proposed upstream;
previous successful runs on sibling branches are provenance, not a
substitute for validation of the final diff.

## Decision if maintainers ask for a split

The agreed single branch remains canonical. Split **only on request**
into an initial foundation PR and a follow-on proof PR, preserving
the complete theorem statements and no artificial weakening.
These splits should be cherry-picked or generated from the unified
candidate, not independently rewritten, to maintain a clear source map.

## Current open checks

- Unified candidate CI: `signed-lap-unified-ci.yml` (result pending at
  time of writing).
- Native-only cycle axiom negative replay: see research branch CI,
  pending, historical mismatch recorded.
- Paranoid external kernel replay: `connection-laplacian-paranoid-comparator.yml`,
  newly configured, no verified completion yet.
- Source-to-semantics theorem map: needs independent elaborated-type and
  definition-body comparison before comprehensive verification can be claimed.

## 2026-11-04 critical self-audit (supersedes earlier pending-status language)

- The clean upstream candidate is `submission/signed-laplacian-unified@ed66c4bc`.
  Its diff against the fork's `master` consists of two files:
  `Mathlib.lean` (+1 import) and `SignedLapMatrix.lean` (+360 lines).
  It does **not** contain the full original connection-Laplacian library.
  It diverges from the fork's master (behind by one master commit);
  the fork itself was at 2026-11-02 while upstream Mathlib master had
  advanced to 2026-11-04. An upstream rebase and exact-head rerun are
  required before a real Mathlib PR.
- **Fresh verification success**:
  [41859739815](https://github.com/jesusvilela/mathlib4/actions/runs/41859739815)
  on `66910992` compiled and linted the unified signed module, performed
  its separate leanchecker pass, and printed the transitive axioms of
  **19 named theorems**. All 19 printed only
  `propext`, `Classical.choice`, and `Quot.sound`.
  The clean candidate's next commit `ed66c4bc` removed only the CI file,
  leaving mathematical source content unchanged. Nevertheless, a passing
  run on one SHA must not be misrepresented as a run on a different SHA.
- **CI checker bug found and corrected**: The old axiom gate only searched
  for `sorryAx`, `native_decide` and `Lean.ofReduceBool`, leaving arbitrary
  unauthorized axiom names undetected by its script (despite clean observed
  output). Furthermore the preserved verification branch carried a CI
  workflow triggered by the submission branch, not itself. Commit
  `f98a45f3` on `verification/signed-laplacian-unified` corrects the
  trigger and enforces an exact 19-name allowlist audit permitting only
  the three standard axioms. Its new run
  [41861086119](https://github.com/jesusvilela/mathlib4/actions/runs/41861086119)
  was in progress during this audit. This fix remains **off** the clean
  upstream candidate.
- **Research spine regression**:
  [41859825052](https://github.com/jesusvilela/mathlib4/actions/runs/41859825052)
  failed during `ConnectionLaplacian.Basic` compilation with
  `unknown module prefix 'Mathlib'`; the other modules were skipped.
  This is a missing dependency/cache/build-setup failure in that CI
  execution, *not* a theorem counterexample. Previously successful spine
  runs remain historical evidence but do not prove that the present research
  HEAD has been freshly rebuilt under that failing workflow.
- **Do not conflate target sets**: 12 accepted native comparator challenge
  statements in the research graph/cycle modules are **different targets**
  from the 19 theorem declarations in the proposed Mathlib signed module.
  The checker validates proof/statement agreement, not source-to-intended-
  mathematics interpretation.
- **Unproved formal bridge**: The original `ConnGraph` uses a predicate
  `G.wrap : G.graph.edgeSet → Prop`; the upstream signed module uses
  `EdgeLabeling Bool`. The candidate compatibility statement is

  ```lean
  -- Research-branch theorem target; not claimed to be compiled.
  G.graph.signedLapMatrix (fun e => decide (G.wrap e))
    = G.signedLaplacianMobius
  ```

  This requires checking the exact elaboration of the edge-labeling
  coercion and the diagonal/off-diagonal definitions. It is not present
  as a proved theorem in the reviewed submission module. A direct bridge
  (plus small analytic sign/convention controls) would supply a better
  source-to-formal-target witness than relying on verbal similarity.
- **Not yet green** at audit time: the revised negative-control matrix
  [41859850561](https://github.com/jesusvilela/mathlib4/actions/runs/41859850561)
  and native `--paranoid` independent checker matrix
  [41859926384](https://github.com/jesusvilela/mathlib4/actions/runs/41859926384).
  The earlier cycle-local-axiom control failed for a *statement mismatch*
  rather than the specified axiom diagnostic; this remains recorded as a
  failed control, even though the comparator did reject it.

No upstream PR was opened, no mathematical statement was altered by this
self-audit, and the one-PR/split-on-maintainer-request intention is intact.

## 2026-11-04 follow-on: exact finite-graph independent oracle

The direct source-to-source matrix theorem was submitted for compilation
in `Porting/MathlibBridge.lean` (commit `968ff57`) and a dedicated Lean CI
run [41863952437](https://github.com/jesusvilela/mathlib4/actions/runs/41863952437)
was queued at last inspection. This is still **H**, not a compiled proof.

An additional independent, standard-library-only Python reference implementation
was committed at `Porting/signed_bridge_oracle.py` (commit `125f70e`),
with its own fork-only CI workflow committed at `5d0933a`.
It exhaustively enumerates `1+1+3+27+729 = 761` labeled simple signed-graph
states on 0..4 vertices. Checks include a research-style off-diagonal
matrix against separately assembled signed `D-A`, exact-rational nullity
versus balanced-component count, quadratic energy and edgewise zero-energy
conditions for `{-1,0,1}^n`, all `2^n` vertex switching assignments,
cyclic vertex relabeling, and two analytic triangle spectra
`{0,3,3}` (all-positive) and `{1,1,4}` (one-negative).

A locally executed, equivalent prototype passed all 761 cases. The
**exact committed script has not yet acquired its GitHub CI verdict**
([run 41864971253](https://github.com/jesusvilela/mathlib4/actions/runs/41864971253),
queued at last inspection). Do not claim this is independent Lean kernel
acceptance: the oracle tests a separately programmed mathematical model,
not the executable Lean definitions.

A separate research-spine CI regression (previous unknown module prefix
`Mathlib`) is being addressed by building imports via Lake rather than
raw `lake env lean`, committed at `0d504ad`. Runs
[41863994087](https://github.com/jesusvilela/mathlib4/actions/runs/41863994087)
and [41863994070](https://github.com/jesusvilela/mathlib4/actions/runs/41863994070)
were queued. The clean upstream submission branch is unchanged.

**Preregistered promotion rule:** Only a completed Lean bridge compile on
the same source blob plus a passing exact reference run promotes
source-to-Mathlib operator correspondence. Neither alone suffices to
establish complete independent verification of the historical development.

## 2026-11-04 completed independent-checker and adversarial checkpoints

- **Research spine**: [run 41863994087](https://github.com/jesusvilela/mathlib4/actions/runs/41863994087), at `0d504ad`, passed the repaired Lake-dependent compilation of all 19 source modules and the trust/axiom audit. The earlier missing-Mathlib import failure was a build-regression, not a mathematical obstruction; the same workflow now passed. This evidence is at that exact research commit, not proof of every later edit.
- **Four negative controls**: [run 41859850561](https://github.com/jesusvilela/mathlib4/actions/runs/41859850561), at `aa3faa2`, completed all four matrix jobs successfully, including a new *native-only* cycle-axiom fixture that the comparator explicitly rejected for its expected "Illegal axiom detected" diagnosis. The historical old fixture's earlier *statement mismatch* remains a negative result and is not erased by this new fixture passing.
- **All 12 research positive targets, paranoid kernels**: [run 41859926384](https://github.com/jesusvilela/mathlib4/actions/runs/41859926384), at `1455cc2`, completed both matrix jobs (7 graph and 5 cycle). Both used `lake comparator --paranoid` inside successful Bubblewrap write-denial checks and returned status **0**. Lean 4.36.0-rc2 documents `--paranoid` as enabling `leanchecker-paranoid`, `lean4lean`, `nanoda`, `con-leche`, and `con-ron`. In this evidence record, do not mistake the separate lean-action nanoda step (which is disabled in that workflow) for proof of external execution: the checkers are invoked by the `lake comparator --paranoid` command.
- **761 exact finite-graph cases**: [run 41864971253](https://github.com/jesusvilela/mathlib4/actions/runs/41864971253), at `5d0933a`, successfully executed the *exact committed* `Porting/signed_bridge_oracle.py` with its signed-matrix, energy, nullity, gauge, relabeling and triangle checks. This is an independent algorithmic/reference test, not a Lean kernel.
- **Missing source correspondence**: [bridge run 41863952437](https://github.com/jesusvilela/mathlib4/actions/runs/41863952437) at `d2cbeca` compiled its imported modules, but the proof failed because `simp` recursively expanded `SimpleGraph.degree` against the default `card_neighborFinset_eq_degree` simplification theorem. The CI log reports maximum recursion depth, not a counterexample. The theorem statement has not been changed. Research commits `d4cdf14` and `cb1c26e` remove explicit unfolding of `SimpleGraph.degree` from all bridge cases; a later CI verdict is still required.
- **Upstream status**: the clean `submission/signed-laplacian-unified` branch and split fallback branches remain unchanged; no upstream PR was opened. The full 19-name allowlisted-axiom CI previously passed on the separate verification branch. Nothing in this ledger extends the 12 research targets to an independent five-kernel replay of all 19 Mathlib public theorem declarations.

**Decision boundary**: continue to block the comprehensive-verification claim until the exact research-to-Mathlib matrix theorem compiles and is itself checked. Review upstream toolchain drift separately before opening a single Mathlib PR.

## 2026-11-04 direct six-checker replay on the unified Mathlib candidate

The research `lake comparator --paranoid` positives covered seven
general-graph and five cycle-spectrum *research* statements; they do
not directly replay the distinct 19 declarations of the Mathlib
`SignedLapMatrix` submission module.

To close that cross-target verification gap, a separate fork-only
workflow was committed on `verification/signed-laplacian-unified`
at `f67c046`:

`.github/workflows/signed-lap-unified-paranoid-ci.yml`

It selects the 19 public Lean theorem declarations directly from
`Mathlib/Combinatorics/SimpleGraph/SignedLapMatrix.lean`, asserts exactly
19 unique names, builds that module, performs an actual Bubblewrap
isolation/host-write-denial test, generates a declaration-selected
NDJSON `leanexport` in a read-only/no-network sandbox, and invokes
`lake check --paranoid --from-export=...` against exactly that export.

The workflow requires explicit successful diagnostics from six kernels:
`Lean paranoid`, `lean4lean`, `nanoda`, `con-leche`,
`con-ron`, and `Lean default`. It archives the SHA, source-blob hash,
selection list and logs. Its first run is
[41872683913](https://github.com/jesusvilela/mathlib4/actions/runs/41872683913),
in progress when this note was written.

**Do not promote** to direct external-kernel verification of the Mathlib
candidate unless that *exact run*, or a later frozen replacement,
finishes all export and checker steps successfully. The corresponding
Mathlib source blob remains
`70af2c839ff1e1274035de4d89a2385cf2cc7d3e`
on the research, clean submission and verification branches.

The earlier research bridge run
[41863952437](https://github.com/jesusvilela/mathlib4/actions/runs/41863952437)
failed because `simp` recursively unfolded
`SimpleGraph.degree` against `card_neighborFinset_eq_degree`.
Two later research commits `d4cdf14` and `cb1c26e` removed that
unfolding without changing the theorem statement. The corrected
[bridge run 41870656627](https://github.com/jesusvilela/mathlib4/actions/runs/41870656627)
remains pending verification. The unchanged source-to-semantics
equality must not be called proved until the actual CI check succeeds.

## 2026-11-04: comprehensive technical verification checkpoint

The previously pending gates finished with definitive CI results:

| Claim | Evidence | Exact SHA under test | Current confidence |
| --- | --- | --- | --- |
| The original Möbius-sector operator equals Mathlib's signed Laplacian for Boolean wrap labels, on every `ConnGraph` admitted by the definitions | [bridge run 41870656627](https://github.com/jesusvilela/mathlib4/actions/runs/41870656627) | `cb1c26e813265c2784f53a84d74c7919632669d4` | **P**: Lean elaborated and kernel-checked the theorem without local axioms or sorries |
| The 19 submitted signed-Laplacian theorem declarations have valid exports accepted by six Lean 4.36 checker configurations, including nanoda | [verification run 41872683913](https://github.com/jesusvilela/mathlib4/actions/runs/41872683913) | `f67c04612ca1b8d0315271fbf79817444824854a`, source blob `70af2c839ff1e1274035de4d89a2385cf2cc7d3e` | **M/P scoped**: actual exported proofs verified; does not itself establish semantic intent |
| The full 19-file original formalization and axiom audit compile after the Lake dependency repair | [spine run 41863994087](https://github.com/jesusvilela/mathlib4/actions/runs/41863994087) | `0d504adf4559eabe611a759436e2ab32c2e934fe` | **P scoped** to compiled declarations and audit |
| Selected positive historical hardening fixtures compile on the new toolchain | [hardening run 41863994070](https://github.com/jesusvilela/mathlib4/actions/runs/41863994070) | `0d504adf4559eabe611a759436e2ab32c2e934fe` | **M**: test compilation; not an independent mathematical proof |
| The four distinct adversarial controls reject for the specified reasons | [negative run 41859850561](https://github.com/jesusvilela/mathlib4/actions/runs/41859850561) | `aa3faa2510bb` | **M**: four expected rejections, including corrected cycle-axiom fixture |
| Seven graph and five cycle challenge targets pass Lean's built-in paranoid comparison | [paranoid run 41859926384](https://github.com/jesusvilela/mathlib4/actions/runs/41859926384) | `1455cc20116d` | **P/M**: scoped proof exports accepted under comparator assumptions |
| Exact finite-graph reference equations, spectral anchors, gauge and relabeling relations | [oracle run 41864971253](https://github.com/jesusvilela/mathlib4/actions/runs/41864971253) | `5d0933a79f76479c332288efb32f010328df84ab` | **M**: 761 states, n ≤ 4; no assertion about larger sampled graphs |

The exact `SignedLapMatrix.lean` blob is shared by the clean submission,
research and verification branches; the latest direct six-checker run
confirmed that precise file hash. The research bridge theorem is separately
verified; it does **not** need to be copied into upstream Mathlib.

**Correction to earlier statements:** The 19 source files of the research
spine are not the same as the 19 public theorem declarations in the Mathlib
signed-Laplacian module. They have different verification targets and must
not be counted interchangeably. The four negative controls validate
specific comparator defenses, not every possible adversarial attempt.
The checker executables are distinct but their errors need not be
probabilistically independent.

### Remaining release conditions

- The direct bridge is presently compiled by Lean's normal kernel.
  Its new `--paranoid` external-kernel replay is in
  [run 41878884925](https://github.com/jesusvilela/mathlib4/actions/runs/41878884925),
  pending at the time of writing.
- The original fork's `master` trailed upstream Mathlib `master` by
  48 commits on 2026-11-04. Using the *then-current* upstream SHA
  `a84939a26903163e1b98ee002bc94e9563e75c12`, an isolated branch
  `verification/signed-laplacian-upstream-current` transplanted the
  **unchanged** 360-line library blob and its one import, and added
  fork-only validation. Its compile/lint/axiom/six-kernel test is
  [run 41879018804](https://github.com/jesusvilela/mathlib4/actions/runs/41879018804),
  queued at the time of this record. The clean submission branch has
  not yet been rebased or overwritten.
- Human maintainer review (API naming, generality, location, and utility)
  remains an external judgment; no number of checking implementations
  can substitute for mathematical exposition and human review.
- Do not open an upstream PR containing `Hardening`, `Porting`, or
  verification workflows. The intended upstream changes remain exactly
  `Mathlib.lean` and `Mathlib/Combinatorics/SimpleGraph/SignedLapMatrix.lean`.

Promotion rule: if the upstream-current experiment passes, designate the
matching two-file, same-source-blob clean branch as the one proposed PR.
Keep the original foundation, extension, research and verification
branches as provenance and optional maintainer-requested split material.

## Upstream-aligned clean submission candidate (4 November 2026)

A non-destructive upstream-base transplant now exists at
`submission/signed-laplacian-unified-current` (head `e282abc5b8e42e93ab6f28322ba0871e6ed82022`),
created directly from `leanprover-community/mathlib4:master@a84939a26903163e1b98ee002bc94e9563e75c12`.
The resulting comparison to that exact upstream base is **0 commits behind,
2 commits ahead, and only two changed files**:

1. `Mathlib.lean`: a single sorted `public import`;
2. `Mathlib/Combinatorics/SimpleGraph/SignedLapMatrix.lean`: identical
   blob `70af2c839ff1e1274035de4d89a2385cf2cc7d3e` (360 lines).

No CI workflows or historical research files belong to that clean diff.
The previous `submission/signed-laplacian-unified` branch is preserved
unchanged as history/fallback, along with the foundation/extension splits.
Only one upstream PR is intended.

The same upstream base and mathematical source were transplanted to
`verification/signed-laplacian-upstream-current`, with a **verification-only**
workflow that checks compilation, Mathlib linting, `mk_all --check`,
strict 19-declaration transitive axiom allowlisting, and direct replay by
the six paranoid checker configurations. The corrected full gate is
[CI run 41879159967](https://github.com/jesusvilela/mathlib4/actions/runs/41879159967),
queued when this entry was added.

A reviewable single-PR draft lives in
[`Porting/mathlib_signed_laplacian_pr_draft.md`](./mathlib_signed_laplacian_pr_draft.md).
It documents only the submitted signed-graph API and carefully separates
research evidence and the full connection-Laplacian development.
**This draft is not an opened PR.** An upstream PR is blocked pending
the current-upstream gate and any forum/maintainer direction on split size.

## 2026-11-04 final verification closure and source-fidelity check

This dated update supersedes earlier **pending** CI language above, without
erasing the chronology of earlier failures and repairs.

### Frozen verification targets

- **Clean proposed Mathlib PR**: `submission/signed-laplacian-unified-current`
  at `e282abc5b8e42e93ab6f28322ba0871e6ed82022`, based directly on
  upstream Mathlib `a84939a26903163e1b98ee002bc94e9563e75c12`.
  The comparison is **0 behind, 2 ahead, 2 files changed**:
  `Mathlib.lean` and
  `Mathlib/Combinatorics/SimpleGraph/SignedLapMatrix.lean`.
  The signed-graph module is exactly blob
  `70af2c839ff1e1274035de4d89a2385cf2cc7d3e` (360 lines).
- **Upstream-current 19-theorem direct replay**:
  [CI 41879159967](https://github.com/jesusvilela/mathlib4/actions/runs/41879159967)
  passed the exact module's build, lint, `mk_all --check`, 19 source-selected
  public theorem exports, transitive axiom allowlist
  (`propext`, `Quot.sound`, `Classical.choice`), Bubblewrap sandbox
  checks and acceptance diagnostics from **Lean paranoid, lean4lean, nanoda,
  con-leche, con-ron, and Lean default**.
- **Research-to-Mathlib matrix identity, independently replayed**:
  [CI 41878884925](https://github.com/jesusvilela/mathlib4/actions/runs/41878884925)
  passed at research commit `cd3bf65f57d84267e069aed6ebfac29e5a8355e1`.
  The imported 4,388-job Lean build succeeded. The actual theorem
  `ConnGraph.signedLaplacianMobius_eq_signedLapMatrix` in
  `Porting/MathlibBridge.lean` compiled, an attempted sandbox host write
  was denied, and its exported statement/proof was accepted by **all six**
  named kernels. The bridge source blob was
  `f6a4492d2f1eefed719afcf6a059ceae0d73a282`.
  Two compiler messages concern *unused simp arguments*, not unproved
  goals or failed checking. This bridge is **research-only**; do not
  move it into the proposed upstream diff without separate review.
- **Research comparator and reference**: the 7+5 research targets were
  accepted by the configured paranoid checker
  ([41859926384](https://github.com/jesusvilela/mathlib4/actions/runs/41859926384));
  four isolated negative controls rejected for intended reasons in the
  current native replay
  ([41859850561](https://github.com/jesusvilela/mathlib4/actions/runs/41859850561)).
  The original cycle-axiom historical fixture previously failed for
  **statement mismatch**, not illicit axiom; the new native-only fixture
  specifically verified the illicit-axiom diagnostic. The independent
  exact-rational oracle passed all 761 signed simple graph assignments
  on 0–4 labeled vertices
  ([41864971253](https://github.com/jesusvilela/mathlib4/actions/runs/41864971253)).
  Finite models are not a universal formal proof.

### Focused legacy source check: orientation double-cover vertex carrier

At the pinned source
[`connection_laplacian_lean@0b4ad40.../ConnectionLaplacian/L5_Cover.lean`](https://github.com/jesusvilela/connection_laplacian_lean/blob/0b4ad40a7dd26d924bd44096eaa5291c3882a67b/ConnectionLaplacian/L5_Cover.lean#L48),
the line is `def CoverV : Type _ := G.V × Bool`.
At the ported
[`ConnectionLaplacian/L5_Cover.lean`](https://github.com/jesusvilela/mathlib4/blob/research/connection-laplacian-full-port/ConnectionLaplacian/L5_Cover.lean#L48),
it is `abbrev CoverV : Type _ := G.V × Bool`.
**The carrier expression and type are textually identical**, while Lean's
reducibility/elaboration behavior can differ. This does not by itself
establish full definitionally elaborated equivalence across toolchains.
Other proof-tactic and Mathlib API adaptations in the file must remain
separate from mathematical-statement changes.

### Remaining boundaries / release decision

- **Still open, full research program**: independent elaborated-type and
  definition-body correspondence for the original 189 theorem/lemma headers
  and 56 declaration headers, especially across toolchain/API adaptations.
  Do not promote textual alignment to this stronger claim.
- **Still open, upstream contribution**: human mathematical and Mathlib
  maintainer review of naming, generality, location, statement usefulness
  and AI-assistance disclosure. The checker implementations are multiple
  but not probabilistically independent proof discoveries.
- **Decision**: keep a **single two-file upstream PR** as the favored
  proposal, with foundation and extension branches preserved solely as
  requested split fallbacks. No upstream PR has been opened and no
  submitted mathematical source has been altered by this documentation
  checkpoint.

For a shorter mathematical explanation suitable for a busy reviewer, read
[`signed_laplacian_human_review.md`](./signed_laplacian_human_review.md).
The frozen PR text is in
[`mathlib_signed_laplacian_pr_draft.md`](./mathlib_signed_laplacian_pr_draft.md).

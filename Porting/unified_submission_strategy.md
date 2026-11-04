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

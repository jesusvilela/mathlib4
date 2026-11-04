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

/-
Copyright (c) 2026 Jesus Vilela Jato. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jesus Vilela Jato
-/

import ConnectionLaplacian.KernelDimension
import Mathlib.Combinatorics.SimpleGraph.SignedLapMatrix

/-!
# Correspondence between research and Mathlib signed graph Laplacians

This module is a research-side bridge: it does NOT belong in the proposed
Mathlib PR. It establishes the precise identification between a proposition
on the edge set in ConnGraph and the Boolean edge labeling in Mathlib.

The bridge is a proof obligation, not evidence of novelty. It must compile
with the actual migrated Lean and Mathlib revisions before it can be cited
as a theorem.
-/

namespace ConnectionLaplacian
namespace ConnGraph

/-- The Boolean signing associated to the research graph's wrap predicate.
A true label means a negative edge. -/
def wrapEdgeLabeling (G : ConnGraph) : G.graph.EdgeLabeling Bool :=
  fun e => decide (G.wrap e)

/-- The research Möbius-sector signed Laplacian is exactly the Mathlib
signed Laplacian for the Boolean wrap-edge labeling.

This is an equality of matrices, not just an agreement of eigenvalues,
energies, or kernel dimensions. -/
theorem signedLaplacianMobius_eq_signedLapMatrix (G : ConnGraph) :
    G.signedLaplacianMobius = G.graph.signedLapMatrix G.wrapEdgeLabeling := by
  classical
  ext u v
  by_cases huv : u = v
  · subst v
    simp [signedLaplacianMobius, SimpleGraph.signedLapMatrix,
      SimpleGraph.signedAdjMatrix, SimpleGraph.degMatrix,
      SimpleGraph.degree, wrapEdgeLabeling]
  · by_cases hadj : G.graph.Adj u v
    · let e : G.graph.edgeSet :=
        ⟨s(u, v), (SimpleGraph.mem_edgeSet G.graph).mpr hadj⟩
      by_cases hw : G.wrap e
      · simp [signedLaplacianMobius, SimpleGraph.signedLapMatrix,
          SimpleGraph.signedAdjMatrix, SimpleGraph.degMatrix,
          SimpleGraph.degree, SimpleGraph.EdgeLabeling.get,
          wrapEdgeLabeling, e, huv, hadj, hw]
      · simp [signedLaplacianMobius, SimpleGraph.signedLapMatrix,
          SimpleGraph.signedAdjMatrix, SimpleGraph.degMatrix,
          SimpleGraph.degree, SimpleGraph.EdgeLabeling.get,
          wrapEdgeLabeling, e, huv, hadj, hw]
    · simp [signedLaplacianMobius, SimpleGraph.signedLapMatrix,
        SimpleGraph.signedAdjMatrix, SimpleGraph.degMatrix,
        SimpleGraph.degree, wrapEdgeLabeling, huv, hadj]

end ConnGraph
end ConnectionLaplacian

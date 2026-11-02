/-
Copyright (c) 2026 Jesús Vilela Jato. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jesús Vilela Jato
-/
module

public import Mathlib.Combinatorics.SimpleGraph.Coloring.EdgeLabeling
public import Mathlib.Combinatorics.SimpleGraph.LapMatrix

/-!
# Signed Laplacian matrices of finite simple graphs

A Boolean edge labeling specifies which edges have negative sign. The signed adjacency
matrix has entry `-1` on negatively signed edges, `1` on other edges, and `0`
on nonedges. The signed Laplacian is the degree matrix minus this adjacency matrix.

When every edge has positive sign, the signed Laplacian is the ordinary graph Laplacian.

This module provides the initial definitions and elementary compatibility lemmas.
-/

@[expose] public section

namespace SimpleGraph

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- The adjacency matrix of a signed graph. An edge labeled `true` has weight `-1`. -/
def signedAdjMatrix (wrap : G.EdgeLabeling Bool) : Matrix V V ℝ :=
  fun u v => if h : G.Adj u v then if wrap.get u v h then -1 else 1 else 0

/-- The signed graph Laplacian `D - Aₛ`, with negative signs on labeled edges. -/
def signedLapMatrix (wrap : G.EdgeLabeling Bool) : Matrix V V ℝ :=
  G.degMatrix ℝ - G.signedAdjMatrix wrap

@[simp]
theorem signedAdjMatrix_apply (wrap : G.EdgeLabeling Bool) (u v : V) :
    G.signedAdjMatrix wrap u v =
      if h : G.Adj u v then if wrap.get u v h then -1 else 1 else 0 := rfl

/-- Signed adjacency matrices are symmetric because the labels belong to unoriented edges. -/
theorem isSymm_signedAdjMatrix (wrap : G.EdgeLabeling Bool) :
    (G.signedAdjMatrix wrap).IsSymm := by
  apply Matrix.IsSymm.ext
  intro u v
  by_cases h : G.Adj u v
  · have h' : G.Adj v u := h.symm
    simp only [signedAdjMatrix_apply, dif_pos h, dif_pos h']
    rw [wrap.get_comm u v h']
  · have h' : ¬ G.Adj v u := fun hv => h hv.symm
    simp [signedAdjMatrix_apply, h, h']

/-- Signed graph Laplacians are symmetric. -/
theorem isSymm_signedLapMatrix (wrap : G.EdgeLabeling Bool) :
    (G.signedLapMatrix wrap).IsSymm := by
  exact (G.isSymm_degMatrix ℝ).sub (G.isSymm_signedAdjMatrix wrap)

/-- When every edge has positive sign, the signed adjacency matrix is ordinary adjacency. -/
@[simp]
theorem signedAdjMatrix_const_false :
    G.signedAdjMatrix (fun _ => false) = G.adjMatrix ℝ := by
  ext u v
  by_cases h : G.Adj u v
  · simp [signedAdjMatrix_apply, EdgeLabeling.get, h]
  · simp [signedAdjMatrix_apply, h]

/-- The all-positive signed Laplacian is the ordinary graph Laplacian. -/
@[simp]
theorem signedLapMatrix_const_false :
    G.signedLapMatrix (fun _ => false) = G.lapMatrix ℝ := by
  rw [signedLapMatrix, G.signedAdjMatrix_const_false]
  rfl

end SimpleGraph

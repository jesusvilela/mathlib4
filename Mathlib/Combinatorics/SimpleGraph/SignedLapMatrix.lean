/-
Copyright (c) 2026 Jesús Vilela Jato. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jesús Vilela Jato
-/
module

public import Mathlib.Combinatorics.SimpleGraph.Coloring.EdgeLabeling
public import Mathlib.Combinatorics.SimpleGraph.LapMatrix

-- The real StarOrderedRing instance is a private import of LapMatrix.
import Mathlib.Algebra.Order.Star.Real

/-!
# Signed Laplacian matrices of finite simple graphs

A Boolean edge labeling specifies which edges have negative sign. The signed adjacency
matrix has entry `-1` on negatively signed edges, `1` on other edges, and `0`
on nonedges. The signed Laplacian is the degree matrix minus this adjacency matrix.

When every edge has positive sign, the signed Laplacian is the ordinary graph Laplacian.

This module provides the initial definitions and elementary compatibility lemmas.
-/

@[expose] public section

open Finset Matrix Module

namespace SimpleGraph

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- The adjacency matrix of a signed graph. An edge labeled `true` has weight `-1`. -/
def signedAdjMatrix (wrap : G.EdgeLabeling Bool) : Matrix V V ℝ :=
  fun u v => if h : G.Adj u v then if wrap.get u v h then -1 else 1 else 0

/-- The signed graph Laplacian `D - Aₛ`, with negative signs on labeled edges. -/
def signedLapMatrix (wrap : G.EdgeLabeling Bool) : Matrix V V ℝ :=
  G.degMatrix ℝ - G.signedAdjMatrix wrap

omit [Fintype V] [DecidableEq V] in
@[simp]
theorem signedAdjMatrix_apply (wrap : G.EdgeLabeling Bool) (u v : V) :
    G.signedAdjMatrix wrap u v =
      if h : G.Adj u v then if wrap.get u v h then -1 else 1 else 0 := rfl

omit [Fintype V] [DecidableEq V] in
/-- On an edge, the signed adjacency entry is `-1` or `1` according to its label. -/
theorem signedAdjMatrix_apply_of_adj (wrap : G.EdgeLabeling Bool) (u v : V)
    (h : G.Adj u v) :
    G.signedAdjMatrix wrap u v = if wrap.get u v h then -1 else 1 := by
  simp [signedAdjMatrix_apply, h]

omit [Fintype V] [DecidableEq V] in
theorem signedAdjMatrix_apply_self (wrap : G.EdgeLabeling Bool) (v : V) :
    G.signedAdjMatrix wrap v v = 0 := by
  simp [signedAdjMatrix_apply]

/-- The diagonal of the signed graph Laplacian is the vertex degree. -/
@[simp]
theorem signedLapMatrix_apply_self (wrap : G.EdgeLabeling Bool) (v : V) :
    G.signedLapMatrix wrap v v = (G.degree v : ℝ) := by
  simp [signedLapMatrix, degMatrix, signedAdjMatrix_apply]

omit [Fintype V] [DecidableEq V] in
/-- Signed adjacency matrices are symmetric because the labels belong to unoriented edges. -/
theorem isSymm_signedAdjMatrix (wrap : G.EdgeLabeling Bool) :
    (G.signedAdjMatrix wrap).IsSymm := by
  apply Matrix.IsSymm.ext
  intro u v
  by_cases h : G.Adj u v
  · have h' : G.Adj v u := h.symm
    simp only [signedAdjMatrix_apply, dite_eq_left h, dite_eq_left h']
    rw [wrap.get_comm u v h']
  · have h' : ¬ G.Adj v u := fun hv => h hv.symm
    simp [signedAdjMatrix_apply, h, h']

/-- Signed graph Laplacians are symmetric. -/
theorem isSymm_signedLapMatrix (wrap : G.EdgeLabeling Bool) :
    (G.signedLapMatrix wrap).IsSymm := by
  exact (G.isSymm_degMatrix ℝ).sub (G.isSymm_signedAdjMatrix wrap)

/-- Over the reals, symmetry implies that the signed Laplacian is Hermitian. -/
theorem isHermitian_signedLapMatrix (wrap : G.EdgeLabeling Bool) :
    (G.signedLapMatrix wrap).IsHermitian := by
  rw [Matrix.IsHermitian, Matrix.conjTranspose_eq_transpose_of_trivial]
  exact G.isSymm_signedLapMatrix wrap

omit [Fintype V] [DecidableEq V] in
/-- When every edge has positive sign, the signed adjacency matrix is ordinary adjacency. -/
@[simp]
theorem signedAdjMatrix_const_false :
    G.signedAdjMatrix (fun _ => false) = G.adjMatrix ℝ := by
  ext u v
  change (if G.Adj u v then (1 : ℝ) else 0) =
    (if G.Adj u v then 1 else 0)
  rfl

/-- The all-positive signed Laplacian is the ordinary graph Laplacian. -/
@[simp]
theorem signedLapMatrix_const_false :
    G.signedLapMatrix (fun _ => false) = G.lapMatrix ℝ := by
  change G.degMatrix ℝ - G.signedAdjMatrix (fun _ => false) =
    G.degMatrix ℝ - G.adjMatrix ℝ
  rw [G.signedAdjMatrix_const_false]

omit [Fintype V] [DecidableEq V] in
/-- If all edges are negative, the signed adjacency matrix is the negative of ordinary
adjacency. -/
@[simp]
theorem signedAdjMatrix_const_true :
    G.signedAdjMatrix (fun _ => true) = -(G.adjMatrix ℝ) := by
  ext u v
  change (if G.Adj u v then (-1 : ℝ) else 0) =
    -(if G.Adj u v then 1 else 0)
  by_cases h : G.Adj u v <;> simp [h]

/-- If all edges are negative, the signed Laplacian is the signless graph Laplacian. -/
@[simp]
theorem signedLapMatrix_const_true :
    G.signedLapMatrix (fun _ => true) = G.degMatrix ℝ + G.adjMatrix ℝ := by
  change G.degMatrix ℝ - G.signedAdjMatrix (fun _ => true) =
    G.degMatrix ℝ + G.adjMatrix ℝ
  rw [G.signedAdjMatrix_const_true, sub_neg_eq_add]

end SimpleGraph

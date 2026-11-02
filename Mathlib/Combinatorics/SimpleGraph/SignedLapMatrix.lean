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

@[simp]
theorem signedAdjMatrix_apply (wrap : G.EdgeLabeling Bool) (u v : V) :
    G.signedAdjMatrix wrap u v =
      if h : G.Adj u v then if wrap.get u v h then -1 else 1 else 0 := rfl

/-- On an edge, the signed adjacency entry is `-1` or `1` according to its label. -/
theorem signedAdjMatrix_apply_of_adj (wrap : G.EdgeLabeling Bool) (u v : V)
    (h : G.Adj u v) :
    G.signedAdjMatrix wrap u v = if wrap.get u v h then -1 else 1 := by
  simp [signedAdjMatrix_apply, h]

@[simp]
theorem signedAdjMatrix_apply_self (wrap : G.EdgeLabeling Bool) (v : V) :
    G.signedAdjMatrix wrap v v = 0 := by
  have h : ¬ G.Adj v v := G.irrefl
  simp [signedAdjMatrix_apply, h]

/-- The diagonal of the signed graph Laplacian is the vertex degree. -/
@[simp]
theorem signedLapMatrix_apply_self (wrap : G.EdgeLabeling Bool) (v : V) :
    G.signedLapMatrix wrap v v = (G.degree v : ℝ) := by
  have h : ¬ G.Adj v v := G.irrefl
  simp [signedLapMatrix, degMatrix, signedAdjMatrix_apply, h]

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

/-- Over the reals, symmetry implies that the signed Laplacian is Hermitian. -/
theorem isHermitian_signedLapMatrix (wrap : G.EdgeLabeling Bool) :
    (G.signedLapMatrix wrap).IsHermitian := by
  rw [Matrix.IsHermitian, Matrix.conjTranspose_eq_transpose_of_trivial]
  exact G.isSymm_signedLapMatrix wrap

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

/-- If all edges are negative, the signed adjacency matrix is the negative of ordinary
adjacency. -/
@[simp]
theorem signedAdjMatrix_const_true :
    G.signedAdjMatrix (fun _ => true) = -(G.adjMatrix ℝ) := by
  ext u v
  by_cases h : G.Adj u v
  · simp [signedAdjMatrix_apply, h]
  · simp [signedAdjMatrix_apply, h]

/-- If all edges are negative, the signed Laplacian is the signless graph Laplacian. -/
@[simp]
theorem signedLapMatrix_const_true :
    G.signedLapMatrix (fun _ => true) = G.degMatrix ℝ + G.adjMatrix ℝ := by
  rw [signedLapMatrix, G.signedAdjMatrix_const_true, sub_neg_eq_add]

/-! ### The signless Laplacian (the all-negative signing) -/

/-- The quadratic form of the signless Laplacian is the sum of squared endpoint sums,
where each unoriented edge occurs twice. -/
theorem signlessLapMatrix_toLinearMap₂' (x : V → ℝ) :
    toLinearMap₂' ℝ (G.degMatrix ℝ + G.adjMatrix ℝ) x x =
      (∑ i : V, ∑ j : V, if G.Adj i j then (x i + x j) ^ 2 else 0) / 2 := by
  simp_rw [toLinearMap₂'_apply', add_mulVec, dotProduct_add, dotProduct_mulVec_degMatrix,
    dotProduct_mulVec_adjMatrix, ← sum_add_distrib, degree_eq_sum_if_adj, sum_mul, ite_mul,
    one_mul, zero_mul, ← sum_add_distrib, ite_add_ite, add_zero]
  rw [← add_self_div_two (∑ i : V, ∑ j : V, _)]
  conv_lhs => enter [1, 2, 2, i, 2, j]; rw [if_congr (adj_comm G i j) rfl rfl]
  conv_lhs => enter [1, 2]; rw [Finset.sum_comm]
  simp_rw [← sum_add_distrib, ite_add_ite]
  congr 2 with i
  congr 2 with j
  ring_nf

/-- The signless graph Laplacian is positive semidefinite. -/
theorem posSemidef_signlessLapMatrix :
    (G.degMatrix ℝ + G.adjMatrix ℝ).PosSemidef := by
  refine .of_dotProduct_mulVec_nonneg ?_ (fun x ↦ ?_)
  · rw [IsHermitian, conjTranspose_eq_transpose_of_trivial]
    exact (G.isSymm_degMatrix ℝ).add (G.isSymm_adjMatrix)
  · rw [star_trivial, ← toLinearMap₂'_apply', G.signlessLapMatrix_toLinearMap₂']
    positivity

/-- In particular, the signed graph Laplacian is positive semidefinite when
all edges are negatively signed. -/
theorem posSemidef_signedLapMatrix_const_true :
    (G.signedLapMatrix (fun _ => true)).PosSemidef := by
  rw [G.signedLapMatrix_const_true]
  exact G.posSemidef_signlessLapMatrix


/-! ### Arbitrary edge signings -/

/-- Every signed adjacency entry on an edge has square one. -/
theorem signedAdjMatrix_sq_apply_of_adj (wrap : G.EdgeLabeling Bool)
    {i j : V} (h : G.Adj i j) :
    (G.signedAdjMatrix wrap i j) * (G.signedAdjMatrix wrap i j) = 1 := by
  simp only [G.signedAdjMatrix_apply_of_adj wrap i j h]
  split_ifs <;> norm_num

/-- Expand the energy of a signed Laplacian into its diagonal and off-diagonal parts. -/
private theorem signedLapMatrix_quadForm_raw (wrap : G.EdgeLabeling Bool) (x : V → ℝ) :
    toLinearMap₂' ℝ (G.signedLapMatrix wrap) x x =
      ∑ i : V, ∑ j : V,
        if G.Adj i j then x i * x i -
          x i * (G.signedAdjMatrix wrap i j * x j) else 0 := by
  have hAdj :
      x ⬝ᵥ (G.signedAdjMatrix wrap *ᵥ x) =
        ∑ i : V, ∑ j : V,
          x i * (G.signedAdjMatrix wrap i j * x j) := by
    simp only [Matrix.dotProduct, Matrix.mulVec]
    simp_rw [Finset.mul_sum]
  have hDegree (i : V) :
      (G.degree i : ℝ) * x i * x i =
        ∑ j : V, if G.Adj i j then x i * x i else 0 := by
    rw [G.degree_eq_sum_if_adj (R := ℝ) i, Finset.sum_mul, Finset.sum_mul]
    apply Finset.sum_congr rfl
    intro j _
    by_cases h : G.Adj i j <;> simp [h]
  have hDeg :
      (∑ i : V, (G.degree i : ℝ) * x i * x i) =
        ∑ i : V, ∑ j : V, if G.Adj i j then x i * x i else 0 :=
    Finset.sum_congr rfl (fun i _ => hDegree i)
  rw [toLinearMap₂'_apply', signedLapMatrix, sub_mulVec, dotProduct_sub,
    dotProduct_mulVec_degMatrix, hAdj, hDeg]
  rw [← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro i _
  rw [← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl
  intro j _
  by_cases h : G.Adj i j
  · simp only [if_pos h]
  · have hzero : G.signedAdjMatrix wrap i j = 0 := by
      simp [signedAdjMatrix_apply, h]
    simp [h, hzero]

/-- The energy of a signed Laplacian is a sum of squared edge differences.

The sum is over *ordered* adjacent vertex pairs, so every undirected
edge occurs twice and the formula includes the factor `1 / 2`.
For a negatively signed edge, the corresponding square is
`(x i + x j) ^ 2`; for a positively signed edge it is
`(x i - x j) ^ 2`. -/
theorem signedLapMatrix_toLinearMap₂' (wrap : G.EdgeLabeling Bool)
    (x : V → ℝ) :
    toLinearMap₂' ℝ (G.signedLapMatrix wrap) x x =
      (∑ i : V, ∑ j : V,
        if G.Adj i j then
          (x i - G.signedAdjMatrix wrap i j * x j) ^ 2 else 0) / 2 := by
  rw [G.signedLapMatrix_quadForm_raw wrap x]
  let A : Matrix V V ℝ := G.signedAdjMatrix wrap
  let S : ℝ := ∑ i : V, ∑ j : V,
    if G.Adj i j then x i * x i - x i * (A i j * x j) else 0
  have hA_symm (i j : V) : A i j = A j i :=
    (G.isSymm_signedAdjMatrix wrap).apply i j
  have hA_sq (i j : V) (h : G.Adj i j) :
      (A i j) * (A i j) = 1 :=
    G.signedAdjMatrix_sq_apply_of_adj wrap h
  have hswap : S = ∑ i : V, ∑ j : V,
      if G.Adj i j then x j * x j - x i * (A i j * x j) else 0 := by
    dsimp only [S]
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro i _
    apply Finset.sum_congr rfl
    intro j _
    by_cases h : G.Adj i j
    · have h' : G.Adj j i := h.symm
      rw [if_pos h', if_pos h, hA_symm j i]
      ring
    · have h' : ¬ G.Adj j i := fun hj => h hj.symm
      simp [h, h']
  have hsum : 2 * S =
      ∑ i : V, ∑ j : V,
        if G.Adj i j then (x i - A i j * x j) ^ 2 else 0 := by
    calc
      2 * S = S + S := by ring
      _ = S + (∑ i : V, ∑ j : V,
          if G.Adj i j then x j * x j - x i * (A i j * x j) else 0) := by
            rw [← hswap]
      _ = ∑ i : V, ∑ j : V,
          if G.Adj i j then (x i - A i j * x j) ^ 2 else 0 := by
        dsimp only [S]
        rw [← Finset.sum_add_distrib]
        apply Finset.sum_congr rfl
        intro i _
        rw [← Finset.sum_add_distrib]
        apply Finset.sum_congr rfl
        intro j _
        by_cases h : G.Adj i j
        · simp only [if_pos h]
          have hsquare : (A i j * x j) * (A i j * x j) = x j * x j := by
            calc
              _ = (A i j * A i j) * (x j * x j) := by ring
              _ = x j * x j := by rw [hA_sq i j h, one_mul]
          calc
            _ = x i * x i + x j * x j - 2 * (x i * A i j * x j) := by ring
            _ = x i * x i + (A i j * x j) * (A i j * x j) -
                2 * (x i * A i j * x j) := by rw [hsquare]
            _ = (x i - A i j * x j) ^ 2 := by ring
        · simp [h]
  change S = (∑ i : V, ∑ j : V,
    if G.Adj i j then (x i - A i j * x j) ^ 2 else 0) / 2
  linarith [hsum]

/-- Every real signed graph Laplacian is positive semidefinite. -/
theorem posSemidef_signedLapMatrix (wrap : G.EdgeLabeling Bool) :
    (G.signedLapMatrix wrap).PosSemidef := by
  refine .of_dotProduct_mulVec_nonneg (G.isHermitian_signedLapMatrix wrap) (fun x ↦ ?_)
  rw [star_trivial, ← toLinearMap₂'_apply', G.signedLapMatrix_toLinearMap₂' wrap x]
  positivity

end SimpleGraph

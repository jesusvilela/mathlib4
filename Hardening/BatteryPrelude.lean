/-
Convention battery PRELUDE (generated, shared by shards A-D).
See Hardening/ConventionBattery.lean header for provenance.
-/
import ConnectionLaplacian

namespace Hardening

open ConnectionLaplacian ConnGraph Matrix BigOperators

set_option maxHeartbeats 4000000

/-- Bridge lemma: lift a `decide`-provable card over a finite type to R. -/
theorem card_filter_univ_cast {α : Type*} [Fintype α] [DecidableEq α]
    (p : α → Prop) [DecidablePred p] (k : ℕ)
    (h : (Finset.filter p Finset.univ).card = k) :
    ((Finset.filter p Finset.univ).card : ℝ) = k := by rw [h]

/-- Entrywise equation for the ordinary Laplacian of a finite connection graph.
This isolates the matrix API from the generated numeric convention fixtures. -/
theorem scalarLaplacian_entry (G : ConnGraph) (u v : G.V) :
    G.scalarLaplacian u v =
      (if u = v then (G.graph.degree u : ℝ) else 0) -
        (if G.graph.Adj u v then (1 : ℝ) else 0) := by
  rfl

/-- A finite filter form of the ordinary Laplacian entry.  It agrees
with the stored graph's adjacency relation while avoiding evaluation of a
noncomputable neighbor-subtype enumeration. -/
theorem scalarLaplacian_entry_filter (G : ConnGraph) (u v : G.V) :
    G.scalarLaplacian u v =
      (if u = v then
        ((Finset.univ.filter (fun w : G.V => G.graph.Adj u w)).card : ℝ)
       else 0) -
      (if G.graph.Adj u v then (1 : ℝ) else 0) := by
  letI : DecidableRel G.graph.Adj := G.decrel
  simpa only [SimpleGraph.degree, SimpleGraph.neighborFinset_eq_filter]
    using (scalarLaplacian_entry G u v)

end Hardening

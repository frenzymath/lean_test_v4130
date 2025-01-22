import LeanTestV4130.Reaper.API
import Lean
import Mathlib

open Lean.Elab.Tactic

/-\n1.7.1. 设 $G$ 作用在集合 $S$ 上, 对任意 $a, b \\in S$, 若存在 $g \\in G$ 使得 $g a=b$,则 $G_{a}=g^{-1} G_{b} g$. 换句话说, 同一轨道中元的固定子群彼此共轭.
-/
example (G : Type*) [Group G] (S : Type*) [MulAction G S] (a b : S) (g : G) (h : g • a = b) : (MulAction.stabilizer G a) = Subgroup.map (MulAut.conj (G := G) g⁻¹) (MulAction.stabilizer G b) := by
  sorry

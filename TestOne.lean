--obvousily card (Π _: Fin n,G) equal to  ∏ _ : Fin n, (card G)= (card G) ^{ n }
example{G:Type*}[Fintype G][Group G] (n:ℕ) :  Fintype.card (Π _: Fin n,G) = (Fintype.card G)^n := sorry
/-Example_5213B-/
/-In an integral domain $R$, if $a\in R$ and natural number $n\in\mathbb N$ satisfy $a^n=0$, then $a=0$.-/
example {R : Type*} [Ring R] [NoZeroDivisors R] (a : R) (n : ℕ) (eq : a ^ n = 0) : a = 0 := sorry
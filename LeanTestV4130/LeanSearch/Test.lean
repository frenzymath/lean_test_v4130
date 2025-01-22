import LeanTestV4130.LeanSearch.API

open Lean

def ppp : CoreM Unit := do
  let s ← (getLeanSearchQueryJson "cauchy theorem" 3)
  IO.println (Json.getObjVal? s[1]! "kind")

#eval (getLeanSearchQueryJson "cauchy theorem" 3)
#eval ppp

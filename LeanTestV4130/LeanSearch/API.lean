import Lean
import Lean.Data.Options

open Lean Meta Elab Tactic Parser Term

register_option leansearch.queries : Nat :=
  { defValue := 6
    group := "leansearch"
    descr := "Number of results requested from leansearch (default 6)" }

register_option leansearchclient.useragent : String :=
  { defValue := "LeanSearchClient"
    group := "leansearchclient"
    descr := "Username for leansearchclient" }

def useragent : CoreM String :=
  return leansearchclient.useragent.get (← getOptions)

initialize leanSearchCache :
  IO.Ref (Std.HashMap (String × Nat) (Array Json)) ← IO.mkRef {}

initialize moogleCache :
  IO.Ref (Std.HashMap String (Array Json)) ← IO.mkRef {}

def getLeanSearchQueryJson (s : String) (num_results : Nat := 6) : CoreM <| Array Json := do
  let cache ← leanSearchCache.get
  match cache.get? (s, num_results) with
  | some jsArr => return jsArr
  | none => do
    let apiUrl := "https://leansearch.net/api/search"
    let s' := System.Uri.escapeUri s
    let q := apiUrl ++ s!"?query={s'}&num_results={num_results}"
    let out ← IO.Process.output {cmd := "curl", args := #["-X", "GET", "--user-agent", ← useragent, q]}
    let js ← match Json.parse out.stdout |>.toOption with
      | some js => pure js
      | none => IO.throwServerError s!"Could not contact LeanSearch server"
    match js.getArr? with
    | Except.ok jsArr => do
      leanSearchCache.modify fun m => m.insert (s, num_results) jsArr
      return jsArr
    | Except.error e =>
      IO.throwServerError s!"Could not obtain array from {js}; error: {e}"

import Lake
open Lake DSL

package "lean_test_v4130" where
  -- add package configuration options here

lean_lib «LeanTestV4130» where
  -- add library configuration options here

require mathlib from git
  "https://github.com/leanprover-community/mathlib4" @ "v4.13.0"

require jixia from git
  "https://github.com/reaslab/jixia.git" @ "v4.13.0"

require REPL from git
  "https://github.com/reaslab/repl.git" @ "v4.13.0"

@[default_target]
lean_exe "lean_test_v4130" where
  root := `Main

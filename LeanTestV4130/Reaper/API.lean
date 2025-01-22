/- Utilities for interacting with LLMlean API endpoints. -/
import Lean
open Lean

structure API where
  model : String
  baseUrl : String
  key : String := ""
deriving Inhabited, Repr

structure GenerationOptions where
  temperature : Float := 0.7
  numSamples : Nat := 10
deriving ToJson

structure OpenAIMessage where
  role : String
  content : String
deriving FromJson, ToJson

structure OpenAITacticGenerationRequest where
  model : String
  messages : List OpenAIMessage
  n : Nat := 5
  temperature : Float := 0.7
  max_tokens : Nat := 100
  stream : Bool := false
deriving ToJson

structure OpenAIChoice where
  message : OpenAIMessage
deriving FromJson

structure OpenAIResponse where
  id : String
  choices : List OpenAIChoice
deriving FromJson

def getAPI : IO API := do
  let url        := (← IO.getEnv "LLMLEAN_ENDPOINT").getD "https://console.siflow.cn/siflow/draco/ai4math/ytwang/reaper-1"
  let model      := (← IO.getEnv "LLMLEAN_MODEL").getD "/AI4M/users/ytwang/LLaMA-Factory/saves/ds_stepprover_algebra_together"
  let apiKey     := (← IO.getEnv "LLMLEAN_API_KEY").getD "awesome-reaper"
  let api : API := {
    model := model,
    baseUrl := url,
    key := apiKey
  }
  return api

def post {α β : Type} [ToJson α] [FromJson β] (req : α) (url : String) (apiKey : String): IO β := do
  let out ← IO.Process.output {
    cmd := "curl"
    args := #[
      "-X", "POST", url,
      "-H", "accept: application/json",
      "-H", "Content-Type: application/json",
      "-H", "Authorization: Bearer " ++ apiKey,
      "-d", (toJson req).pretty UInt64.size]
  }
  if out.exitCode != 0 then
     throw $ IO.userError s!"Request failed. If running locally, ensure that ollama is running, and that the ollama server is up at `{url}`. If the ollama server is up at a different url, set LLMLEAN_URL to the proper url. If using a cloud API, ensure that LLMLEAN_API_KEY is set."
  let some json := Json.parse out.stdout |>.toOption
    | throw $ IO.userError out.stdout
  let some res := (fromJson? json : Except String β) |>.toOption
    | throw $ IO.userError out.stdout
  return res


def splitTac (text : String) : String :=
  let text := text.replace "[TAC]" ""
  match (text.splitOn "[/TAC]").head? with
  | some s => s.trim
  | none => text.trim

def filterGeneration (s: String) : Bool :=
  let banned := ["sorry", "admit", "▅"]
  !(banned.any fun s' => (s.splitOn s').length > 1)

def parseTacticResponseOpenAI (res: OpenAIResponse) (pfx : String) : Array String :=
  (res.choices.map fun x => pfx ++ (splitTac x.message.content)).toArray

def tacticGenerationOpenAI (pfx : String) (prompts : List String)
(api : API) (options : GenerationOptions) : IO $ Array (String × Float) := do
  let mut results : Std.HashSet String := Std.HashSet.empty
  for prompt in prompts do
    let req : OpenAITacticGenerationRequest := {
      model := api.model,
      messages := [
        {
          role := "user",
          content := prompt
        }
      ],
      n := options.numSamples,
      temperature := options.temperature
    }
    let res : OpenAIResponse ← post req api.baseUrl api.key
    for result in (parseTacticResponseOpenAI res pfx) do
      results := results.insert result

  let finalResults := (results.toArray.filter filterGeneration).map fun x => (x, 1.0)
  return finalResults

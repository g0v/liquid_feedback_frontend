ui.title(_"Policies")

util.help("policy.list", _"Policies")

execute.view{
  module = "policy",
  view = "_list",
  params = {
    admin = false,
    policies = Policy:build_selector{ active = true }:exec()
  }
}

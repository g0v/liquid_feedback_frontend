local issue = param.get("issue", "table")

execute.view{
  module = "initiative",
  view = "_list",
  params = { 
    issue = issue,
    initiatives_selector = issue:get_reference_selector("initiatives")
  }
}

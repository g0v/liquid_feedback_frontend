local issue = param.get("issue", "table")

ui.container{
  attr = { class = "issue_initiative_list" },
  content = function()
    execute.view{
      module = "initiative",
      view = "_list",
      params = {
        initiatives_selector = issue:get_reference_selector("initiatives"),
        issue = issue,
        expandable = true,
        for_initiative_id = param.get("for_initiative_id", atom.number),
        xshow_for_issue = true,
        no_sort = true
      }
    }
  end
}

slot.put("<br />")

local initiative = param.get("initiative", "table")

if not initiative then
  initiative = Initiative:new_selector():add_where{ "id = ?", param.get_id()}:single_object_mode():exec()
end

execute.view{
  module = "issue",
  view = "_show_head",
  params = { issue = initiative.issue,
             initiative = initiative }
}


execute.view{
  module = "initiative",
  view = "show_partial",
  params = {
    initiative = initiative,
    expanded = true
  }
}

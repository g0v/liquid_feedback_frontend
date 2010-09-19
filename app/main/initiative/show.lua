local initiative = param.get("initiative", "table")

if not initiative then
  initiative = Initiative:new_selector():add_where{ "id = ?", param.get_id()}:single_object_mode():exec()
end

app.html_title.title = initiative.name
app.html_title.subtitle = _("Initiative ##{id}", { id = initiative.id })


if request.get_json_request_slots() then
  execute.view{
    module = "initiative",
    view   = "show_partial",
    params = {
      initiative = initiative
    }
  }
elseif
  config.user_tab_mode == "accordeon" or
  config.user_tab_mode == "accordeon_first_expanded" or
  config.user_tab_mode == "accordeon_all_expanded"
then
  execute.view{
    module = "issue",
    view   = "show",
    id     = initiative.issue_id,
    params = {
      for_initiative_id = initiative.id
    }
  }
else
  execute.view{
    module = "initiative",
    view   = "show_static",
    params = {
      initiative = initiative
    }
  }
end

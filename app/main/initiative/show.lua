local initiative = param.get("initiative", "table")

if not initiative then
  initiative = Initiative:new_selector():add_where{ "id = ?", param.get_id()}:single_object_mode():exec()
end

app.html_title.title = initiative.name
app.html_title.subtitle = _("Initiative ##{id}", { id = initiative.id })


execute.view{
  module = "issue",
  view = "_show_head",
  params = { issue = initiative.issue,
             initiative = initiative }
}

if not initiative then
  initiative = Initiative:by_id(param.get_id())
  expanded = true
end

-- TODO performance
local initiator
if app.session.member_id then
  initiator = Initiator:by_pk(initiative.id, app.session.member.id)
end

execute.view{
  module = "initiative",
  view = "_show",
  params = {
    initiative = initiative,
    initiator = initiator
  }
}

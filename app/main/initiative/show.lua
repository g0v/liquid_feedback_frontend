local initiative = Initiative:by_id(param.get_id())

local issue = initiative.issue

if app.session.member_id then
  issue:load_everything_for_member_id(app.session.member_id)
end

app.html_title.title = initiative.name
app.html_title.subtitle = _("Initiative ##{id}", { id = initiative.id })

slot.select("head", function()
  execute.view{
    module = "issue", view = "_head",
    params = { issue = issue, initiative = initiative }
  }
end)
  
execute.view{
  module = "initiative",
  view = "_show",
  params = {
    initiative = initiative,
    initiator = initiator
  }
}

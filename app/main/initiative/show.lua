local initiative = Initiative:by_id(param.get_id())

app.html_title.title = initiative.name
app.html_title.subtitle = _("Initiative ##{id}", { id = initiative.id })

slot.select("head", function()
  execute.view{
    module = "issue", view = "_head",
    params = { issue = initiative.issue, initiative = initiative }
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

local issue = Issue:by_id(param.get_id())
if app.session.member_id then
  issue:load_everything_for_member_id(app.session.member_id)
end

if not app.html_title.title then
	app.html_title.title = _("Issue ##{id}", { id = issue.id })
end

slot.select("head", function()
  execute.view{ module = "area", view = "_head", params = { area = issue.area } }
end)

util.help("issue.show")

slot.select("head", function()
  execute.view{ module = "issue", view = "_show", params = { issue = issue } }
end )


execute.view{
  module = "issue",
  view = "show_tab",
  params = { issue = issue }
}

if issue.snapshot then
  slot.put("<br />")
  ui.field.timestamp{ label = _"Last snapshot:", value = issue.snapshot }
end


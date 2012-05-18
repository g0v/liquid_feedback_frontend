if not app.session.member_id then
  error("access denied")
end

app.html_title.title = _("Member menu")

execute.view{
  module = "member",
  view = "_menu"
}


ui.title(_"Delete your personal data and deactivate your account")

util.help("member.settings.delete", _"Delete personal data and deactivate account")

ui.form{
  attr = { class = "vertical" },
  module = "member",
  action = "update_delete",
  content = function()
    ui.field.boolean{ label = _"Create a new account?", name = "resurrect" }
    ui.field.boolean{ label = _"Are you sure?", name = "sure" }
    slot.put("<br/>")
    ui.submit{ value = _"Delete your personal data and deactivate your account" }
  end
}

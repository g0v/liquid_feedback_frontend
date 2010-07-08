slot.put_into("title", _"Change your notification email address")

slot.select("actions", function()
  ui.link{
    content = function()
        ui.image{ static = "icons/16/cancel.png" }
        slot.put(_"Cancel")
    end,
    module = "member",
    view = "settings"
  }
end)

util.help("member.settings.email_address", _"Change email")

ui.form{
  attr = { class = "vertical" },
  module = "member",
  action = "update_email",
  routing = {
    ok = {
      mode = "redirect",
      module = "index",
      view = "index"
    }
  },
  content = function()
    if app.session.member.notify_email then
      ui.field.text{ label = _"Confirmed address", value = app.session.member.notify_email, readonly = true }
    end
    if app.session.member.notify_email_unconfirmed then
      ui.field.text{ label = _"Unconfirmed address", value = app.session.member.notify_email_unconfirmed, readonly = true }
    end
    ui.field.text{ label = _"New address", name = "email" }
    ui.submit{ value = _"Change email" }
  end
}


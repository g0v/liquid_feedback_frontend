slot.put_into("title", _"Change your login")

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

util.help("member.settings.login", _"Change login")

ui.form{
  attr = { class = "vertical" },
  module = "member",
  action = "update_login",
  routing = {
    ok = {
      mode = "redirect",
      module = "index",
      view = "index"
    }
  },
  content = function()
    ui.field.text{ label = _"Login", name = "login", value = app.session.member.login }
    ui.submit{ value = _"Change login" }
  end
}


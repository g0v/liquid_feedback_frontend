
slot.put_into("title", _"Settings")

slot.select("actions", function()
  ui.link{
    content = function()
        ui.image{ static = "icons/16/cancel.png" }
        slot.put(_"Cancel")
    end,
    module = "index",
    view = "index"
  }
end)

ui.heading{ content = _"Change your name" }
util.help("member.settings.name", _"Change name")

ui.form{
  attr = { class = "vertical" },
  module = "member",
  action = "update_name",
  routing = {
    ok = {
      mode = "redirect",
      module = "index",
      view = "index"
    }
  },
  content = function()
    ui.field.text{ label = _"Name", name = "name", value = app.session.member.name }
    ui.submit{ value = _"Change name" }
  end
}

ui.heading{ content = _"Change your login" }
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

ui.heading{ content = _"Change your password" }
util.help("member.settings.password", _"Change password")

ui.form{
  attr = { class = "vertical" },
  module = "member",
  action = "update_password",
  routing = {
    ok = {
      mode = "redirect",
      module = "index",
      view = "index"
    }
  },
  content = function()
    ui.field.password{ label = _"Old password", name = "old_password" }
    ui.field.password{ label = _"New password", name = "new_password1" }
    ui.field.password{ label = _"Repeat new password", name = "new_password2" }
    ui.submit{ value = _"Change password" }
  end
}


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

  ui.link{
    content = function()
        ui.image{ static = "icons/16/wrench.png" }
        slot.put(_"Developer features")
    end,
    module = "member",
    view = "developer_settings"
  }

end)

ui.heading{ content = _"Display settings" }
util.help("member.settings.display", _"Display settings")

ui.form{
  attr = { class = "vertical" },
  module = "member",
  action = "update_display",
  routing = {
    ok = {
      mode = "redirect",
      module = "index",
      view = "index"
    }
  },
  content = function()
    ui.field.select{
      label = _"Type of tabs",
      foreign_records = {
        { id = "tabs",                     name = _"Tabs" },
        { id = "accordeon",                name = _"Accordion (none expanded)" .. " === " .. _"EXPERIMENTAL FEATURE" .. " ===" },
        { id = "accordeon_first_expanded", name = _"Accordion (first expanded)" .. " === " .. _"EXPERIMENTAL FEATURE" .. " ===" },
--        { id = "accordeon_all_expanded",   name = _"Accordion (all expanded)" }
      },
      foreign_id = "id",
      foreign_name = "name",
      name = "tab_mode",
      value = app.session.member:get_setting_value("tab_mode")
    }
    ui.field.select{
      label = _"Number of initiatives to preview",
      foreign_records = {
        { id =  3, name = "3" },
        { id =  4, name = "4" },
        { id =  5, name = "5" },
        { id =  6, name = "6" },
        { id =  7, name = "7" },
        { id =  8, name = "8" },
        { id =  9, name = "9" },
        { id = 10, name = "10" },
      },
      foreign_id = "id",
      foreign_name = "name",
      name = "initiatives_preview_limit",
      value = app.session.member:get_setting_value("initiatives_preview_limit")
    }
    ui.submit{ value = _"Change display settings" }
  end
}

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
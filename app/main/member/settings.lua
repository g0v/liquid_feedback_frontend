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

ui.tag{
  tag = "div",
  content = _"You can change the following settings:"
}

local pages = {
  { view = "settings_display",   text = _"Display settings" },
  { view = "settings_email",     text = _"Change your notification email address" },
  { view = "settings_name",      text = _"Change your name" },
  { view = "settings_login",     text = _"Change your login" },
  { view = "settings_password",  text = _"Change your password" },
  { view = "developer_settings", text = _"Developer settings" },
}

ui.list{
  attr = { class = "menu_list" },
  style = "ulli",
  records = pages,
  columns = {
    {
      content = function(page)
        ui.link{
          module = "member",
          view = page.view,
          text = page.text
        }
      end
    }
  }
}


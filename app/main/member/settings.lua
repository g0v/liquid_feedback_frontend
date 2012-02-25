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

local pages = {}

pages[#pages+1] = { module = "member", view = "edit", text = _"Edit profile" }
pages[#pages+1] = { module = "member", view = "edit_images", text = _"Upload images" }
pages[#pages+1] = { view = "settings_notification", text = _"Notification settings" }
pages[#pages+1] = { view = "settings_display",        text = _"Display settings" }
if not config.locked_profile_fields.notify_email then
  pages[#pages+1] = { view = "settings_email",          text = _"Change your notification email address" }
end
if not config.locked_profile_fields.name then
  pages[#pages+1] = { view = "settings_name",           text = _"Change your screen name" }
end
if not config.locked_profile_fields.login then
  pages[#pages+1] = { view = "settings_login",          text = _"Change your login" }
end
pages[#pages+1] = { view = "settings_password",       text = _"Change your password" }
pages[#pages+1] = { view = "developer_settings",      text = _"Developer settings" }

ui.list{
  attr = { class = "menu_list" },
  style = "ulli",
  records = pages,
  columns = {
    {
      content = function(page)
        ui.link{
          module = page.module or "member",
          view = page.view,
          text = page.text
        }
      end
    }
  }
}


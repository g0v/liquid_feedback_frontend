slot.put_into("title", _"Developer settings")

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

  local setting_key = "liquidfeedback_frontend_developer_features"
  local setting = Setting:by_pk(app.session.member.id, setting_key)

  if setting then
    ui.form{
      attr = { class = "vertical" },
      module = "member",
      action = "update_stylesheet_url",
      routing = {
        ok = {
          mode = "redirect",
          module = "index",
          view = "index"
        }
      },
      content = function()
        local setting_key = "liquidfeedback_frontend_stylesheet_url"
        local setting = Setting:by_pk(app.session.member.id, setting_key)
        local value = setting and setting.value
        ui.field.text{ 
          label = _"Stylesheet URL",
          name = "stylesheet_url",
          value = value
        }
        ui.submit{ value = _"Set URL" }
      end
    }
  end

  local setting_key = "liquidfeedback_frontend_api_key"
  local setting = Setting:by_pk(app.session.member.id, setting_key)
  local api_key
  if setting then
    api_key = setting.value
  end

  ui.heading{ content = _"Generate / change API key" }
  util.help("member.developer_settings.api_key", _"API key")

  if api_key then
    slot.put(_"Your API key:")
    slot.put(" ")
    slot.put("<tt>", api_key, "</tt>")
    slot.put(" ")
    ui.link{
      text = _"Change API key",
      module = "member",
      action = "update_api_key",
      routing = {
        default = {
          mode = "redirect",
          module = "member",
          view = "developer_settings"
        }
      }
    }
    slot.put(" ")
    ui.link{
      text = _"Delete API key",
      module = "member",
      action = "update_api_key",
      params = { delete = true },
      routing = {
        default = {
          mode = "redirect",
          module = "member",
          view = "developer_settings",
        }
      }
    }
  else
    slot.put(_"Currently no API key is set.")
    slot.put(" ")
    ui.link{
      text = _"Generate API key",
      module = "member",
      action = "update_api_key",
      routing = {
        default = {
          mode = "redirect",
          module = "member",
          view = "developer_settings"
        }
      }
    }
  end

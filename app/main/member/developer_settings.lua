slot.put_into("title", _"Developer features")

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

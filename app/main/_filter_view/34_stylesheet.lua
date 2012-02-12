local value
if app.session.member then
  local setting_key = "liquidfeedback_frontend_stylesheet_url"
  local setting = Setting:by_pk(app.session.member.id, setting_key)
  value = setting and setting.value
end

if value then
  slot.put_into("stylesheet_url", value)
else
  slot.put_into("stylesheet_url", config.absolute_base_url .. "static/style.css")
end

execute.inner()

if config.footer_html then 
  slot.put_into("footer", config.footer_html)
end
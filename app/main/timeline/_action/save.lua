local id = param.get("id", atom.number)

local setting_key = "liquidfeedback_frontend_timeline_current_options"
local setting = Setting:by_pk(app.session.member.id, setting_key)
local options_string = setting.value

local timeline_filter

local subkey = param.get("name")

setting_map = SettingMap:new()
setting_map.member_id = app.session.member.id
setting_map.key = "timeline_filters"
setting_map.subkey = subkey
setting_map.value = options_string
setting_map:save()

local timeline_params = {}
if options_string then
  for event_ident, filter_idents in setting.value:gmatch("(%S+):(%S+)") do
    timeline_params["option_" .. event_ident] = true
    if filter_idents ~= "*" then
      for filter_ident in filter_idents:gmatch("([^\|]+)") do
        timeline_params["option_" .. event_ident .. "_" .. filter_ident] = true
      end
    end
  end
end

local setting_key = "liquidfeedback_frontend_timeline_current_date"
local setting = Setting:by_pk(app.session.member.id, setting_key)

if setting then
  timeline_params.date = setting.value
end

request.redirect{
  module = "timeline",
  view = "index",
  params = timeline_params
}
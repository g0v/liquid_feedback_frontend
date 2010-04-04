if not config.api_enabled then
  error("API is not enabled.")
end

local api_key = param.get("key")

if not api_key then
  error("No API key supplied.")
end

local setting_key = "liquidfeedback_frontend_api_key"

local setting = Setting:new_selector()
  :add_where{ "key = ?", setting_key }
  :add_where{ "value = ?", api_key }
  :join("member", nil, "member.id = setting.member_id")
  :add_where("member.active")
  :optional_object_mode()
  :exec()

if not setting then
  error("Supplied API key is not valid.")
end

execute.inner()

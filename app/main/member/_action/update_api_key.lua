
local setting_key = "liquidfeedback_frontend_api_key"
local setting = Setting:by_pk(app.session.member.id, setting_key)

local api_key

if param.get("delete", atom.boolean) then

  if setting then
    setting:destroy()
  end

else

  if not setting then
    setting = Setting:new()
    setting.member_id = app.session.member.id
    setting.key = setting_key
  end

  api_key = multirand.string(
    20,
    '23456789BCDFGHJKLMNPQRSTVWXYZbcdfghjkmnpqrstvwxyz'
  )

  setting.value = api_key

  setting:save()
end


local setting_key = "liquidfeedback_frontend_api_key_history"

setting = SettingMap:new()
setting.member_id = app.session.member.id
setting.key = setting_key
setting.subkey = db:query("SELECT now()")[1].now
setting.value = api_key or ""
local dberr = setting:try_save()

if dberr then
  if dberr:is_kind_of("IntegrityConstraintViolation.UniqueViolation") then
    slot.put_into("error", _"The API key has been changed too fast.")
    return
  else
    dberr:escalate()
  end
end

if not api_key then
  slot.put_into("notice", _"API key has been deleted")
else
  slot.put_into("notice", _"API key has been updated")
end

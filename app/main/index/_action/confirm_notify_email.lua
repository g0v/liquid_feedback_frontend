local secret = param.get("secret")

local member = Member:new_selector()
  :add_where{ "notify_email_secret = ?", secret }
  :add_where("notify_email_secret_expiry > now()")
  :optional_object_mode()
  :exec()

if member then
  member.notify_email = member.notify_email_unconfirmed
  member.notify_email_unconfirmed = nil
  member.notify_email_secret = nil
  member:save()
  slot.put_into("notice", _"Email address is confirmed now")
else
  slot.put_into("error", _"Confirmation code invalid!")
  return false
end

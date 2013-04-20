--trace.disable()

local email = param.get("email")

local members = Member:new_selector()
  :add_where{ "notify_email = ? OR notify_email_unconfirmed = ?", email, email }
  :add_where("login_recovery_expiry ISNULL OR login_recovery_expiry < now()")
  :exec()

if #members < 1 then
  return
end
  
local logins = {}

for i, member in ipairs(members) do
  local expiry = db:query("SELECT now() + '7 days'::interval as expiry", "object").expiry
  member.login_recovery_expiry = expiry
  member:save()
  logins[#logins+1] = member.login
end

local content = slot.use_temporary(function()
  slot.put(_"Hello,\n\n")
  slot.put(_"the following login is connected to this email address:\n\n")
  for i, login in ipairs(logins) do
    slot.put(_"Login-Name: " .. login .. "\n")
  end
end)

trace.debug(content)
if true then return end

local success = net.send_mail{
  envelope_from = config.mail_envelope_from,
  from          = config.mail_from,
  reply_to      = config.mail_reply_to,
  to            = email,
  subject       = config.mail_subject_prefix .. _"Login name request",
  content_type  = "text/plain; charset=UTF-8",
  content       = content
}

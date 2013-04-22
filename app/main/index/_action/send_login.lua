if not config.send_login then
  slot.put_into("error", _"This function is not activated!")
  return false
end

local email = util.trim(param.get("email"))

if not email:match('^[^@%s]+@[^@%s]+$') then
  slot.put_into("error", _"This email address is not valid!")
  return false
end

local members = Member:new_selector()
  :add_where{ "split_part(notify_email, '@', 1) = split_part(?, '@', 1)", email }
  :add_where{ "lower(split_part(notify_email, '@', 2)) = lower(split_part(?, '@', 2))", email }
  :add_where("login_recovery_expiry ISNULL OR login_recovery_expiry < now()")
  :exec()

if #members > 0 then

  local expiry = db:query("SELECT now() + '7 days'::interval as expiry", "object").expiry
  for i, member in ipairs(members) do
    member.login_recovery_expiry = expiry
    member:save()
  end

  local content = slot.use_temporary(function()
    slot.put(_"Hello!" .. "\n\n")
    slot.put(_"The following login is connected to this email address:" .. "\n\n")
    for i, member in ipairs(members) do
      slot.put(_"Login name" .. ": " .. member.login .. "\n")
    end
  end)
  local success = net.send_mail{
    envelope_from = config.mail_envelope_from,
    from          = config.mail_from,
    reply_to      = config.mail_reply_to,
    to            = email,
    subject       = config.mail_subject_prefix .. _"Login name request",
    content_type  = "text/plain; charset=UTF-8",
    content       = content
  }

end

slot.put_into("notice", _"If a member with this email address exists, the login name has been sent.")

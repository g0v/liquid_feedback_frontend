local code = util.trim(param.get("code"))

-- optionally allow registration without invite code
if config.register_without_invite_code and code == '' then
  -- create new member
  code = multirand.string( 24, "23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz" )
  local member = Member:new()
  member.invite_code = code
  member:save()
  -- grant voting right in all existing units
  local units = Unit:new_selector()
    :add_field("privilege.member_id NOTNULL", "privilege_exists")
    :add_field("privilege.voting_right", "voting_right")
    :left_join("privilege", nil, { "privilege.member_id = ? AND privilege.unit_id = unit.id", member.id })
    :exec()
  for i, unit in ipairs(units) do
    if not unit.privilege_exists then
      local privilege = Privilege:new()
      privilege.unit_id = unit.id
      privilege.member_id = member.id
      privilege.voting_right = true
      privilege:save()
    end
  end
  -- jump to step 2
  request.redirect{
    mode   = "forward",
    module = "index",
    view   = "register",
    params = { code = code, step2 = 1 }
  }
end

local member = Member:new_selector()
  :add_field( "now() > invite_code_expiry", "invite_code_expired" )
  :add_where{ "invite_code = ?", code }
  :add_where{ "activated ISNULL" }
  :add_where{ "NOT locked" }
  :add_where{ "NOT locked_import" }
  :optional_object_mode()
  :for_update()
  :exec()

if not member then
  slot.put_into("error", _"The code you've entered is invalid!")
  -- jump to step 1
  request.redirect{
    mode   = "forward",
    module = "index",
    view   = "register",
    params = { code = code }
  }
  return false
end

if config.invite_code_expiry and member.invite_code_expired then
  slot.put_into("error", _("The code you've entered is expired! Please contact #{support} to get a new one!", { support = '<a href="mailto:' .. config.support .. '">' .. config.support .. '</a>' }))
  -- jump to step 1
  request.redirect{
    mode   = "forward",
    module = "index",
    view   = "register",
    params = { code = code }
  }
  return false
end

-- check the input from the step 2 form only if this form was submitted
if not param.get("step2") then
  return
end

local notify_email = util.trim(param.get("notify_email"))
local name         = util.trim(param.get("name"))
local login        = util.trim(param.get("login"))
local password1    = param.get("password1")
local password2    = param.get("password2")

if config.locked_profile_fields.notify_email then

  if not member.notify_email then
    slot.put_into("error", _"This invite code has no email address assigned!")
    -- jump to step 1
    request.redirect{
      mode   = "forward",
      module = "index",
      view   = "register",
      params = { code = member.invite_code }
    }
    return false
  end

else

  if not notify_email:match('^[^@%s]+@[^@%s]+$') then
    slot.put_into("error", _"This email address is not valid!")
    return false
  end

end

if config.locked_profile_fields.name then

  if not member.name then
    slot.put_into("error", _"This invite code has no screen name assigned!")
    -- jump to step 1
    request.redirect{
      mode   = "forward",
      module = "index",
      view   = "register",
      params = { code = member.invite_code }
    }
    return false
  end

else

  if #name < 3 then
    slot.put_into("error", _"This screen name is too short!")
    return false
  end

  local check_member = Member:by_name(name)
  if check_member and check_member.id ~= member.id then
    slot.put_into("error", _"This name is already taken, please choose another one!")
    return false
  end

  member.name = name

end

if config.locked_profile_fields.login then

  if not member.login then
    slot.put_into("error", _"This invite code has no login assigned!")
    -- jump to step 1
    request.redirect{
      mode   = "forward",
      module = "index",
      view   = "register",
      params = { code = member.invite_code }
    }
    return false
  end

else

  if #login < 3 then
    slot.put_into("error", _"This login is too short!")
    return false
  end

  local check_member = Member:by_login(login)
  if check_member and check_member.id ~= member.id then
    slot.put_into("error", _"This login is already taken, please choose another one!")
    return false
  end

  member.login = login

end

if password1 ~= password2 then
  slot.put_into("error", _"Passwords don't match!")
  return false
end

if #password1 < 8 then
  slot.put_into("error", _"Passwords must consist of at least 8 characters!")
  return false
end

for i, checkbox in ipairs(config.use_terms_checkboxes) do
  local accepted = param.get("use_terms_checkbox_" .. checkbox.name, atom.boolean)
  if not accepted then
    slot.put_into("error", checkbox.not_accepted_error)
    return false
  end
end

if notify_email ~= member.notify_email then
  local success = member:set_notify_email(notify_email)
  if not success then
    slot.put_into("error", _"Can't send confirmation email!")
    return false
  end
end

member:set_password(password1)

local now = db:query("SELECT now() AS now", "object").now

for i, checkbox in ipairs(config.use_terms_checkboxes) do
  local accepted = param.get("use_terms_checkbox_" .. checkbox.name, atom.boolean)
  member:set_setting("use_terms_checkbox_" .. checkbox.name, "accepted at " .. tostring(now))
end

member.activated = 'now'
member.active = true
member.last_activity = 'now'
member:save()

slot.put_into("notice", _"You've successfully registered and you can login now with your login and password!")

request.redirect{
  mode   = "redirect",
  module = "index",
  view   = "login",
}

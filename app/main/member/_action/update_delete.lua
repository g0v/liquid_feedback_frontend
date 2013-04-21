local sure = param.get("sure", atom.boolean)
if not sure then
  slot.put_into("error", "You have to mark 'Are you sure' to perform this action!")
  return false
end

local resurrect = param.get("resurrect", atom.boolean)

local member_old = Member:by_id(app.session.member_id)
local member_new

if resurrect then

  -- prepare new member
  member_new = Member:new()
  -- same identification to avoid breaking automatic member updates
  member_new.identification = member_old.identification
  -- same mail for the invitation
  member_new.notify_email = member_old.notify_email

  -- delete identification of old member first to satisfy UNIQUE constraint
  member_old.identification = nil
  member_old:save()

  -- save new member
  local err = member_new:try_save()
  if err then
    slot.put_into("error", (_("Error while inserting new member, database reported:<br /><br /> (#{errormessage})"):gsub("#{errormessage}", tostring(err.message))))
    -- rollback
    member_old.identification = member_new.identification
    member_old:save()
    return false
  end

  -- copy privileges
  local units = Unit:new_selector()
    :add_field("privilege.member_id NOTNULL", "privilege_exists")
    :add_field("privilege.voting_right", "voting_right")
    :left_join("privilege", nil, { "privilege.member_id = ? AND privilege.unit_id = unit.id", member_old.id })
    :exec()
  for i, unit in ipairs(units) do
    if unit.privilege_exists then
      local privilege = Privilege:new()
      privilege.unit_id = unit.id
      privilege.member_id = member_new.id
      privilege.voting_right = true
      privilege:save()
    end
  end

  member_new:send_invitation()

end

-- delete personal data of the old member
db:query("SELECT delete_member(" .. member_old.id .. ")")

-- logout
if app.session then
  app.session:destroy()
  if config.etherpad then
    request.set_cookie{
      path = config.etherpad.cookie_path,
      name = "sessionID",
      value = "invalid"
    }
  end
end

if resurrect then
  slot.put_into("notice", _("Your personal data has been deleted and your account has been deactivated. A new account has been created for you. The invite code has been filled in the registration form below and also sent to you by email. Proceed with the registration to activate your new account!", { invite = member_new.invite_code }))
  -- jump to registration
  request.redirect{
    mode   = "forward",
    module = "index",
    view   = "register",
    params = { invite = member_new.invite_code }
  }
else
  slot.put_into("notice", _"Your personal data has been deleted and your account has been deactivated.")
  -- jump to start
  request.redirect{
    mode   = "forward",
    module = "index",
    view   = "index"
  }
end
local id = param.get_id()
local member = Member:by_id(id) or Member:new()

if param.get("delete_member", atom.boolean) then
  db:query("SELECT delete_member(" .. member.id .. ")")
  slot.put_into("notice", _"Personal data deleted and account deactivated")
  return
end

-- status operations
if param.get("lock_and_deactivate", atom.boolean) then
  -- It does not make sense to lock a member, but let its delegations stay active, so we lock and deactivate as one operation.
  member.locked = true
  member.active = false
end
if param.get("unlock", atom.boolean) then
  -- When we unlock a member, it is not necessary to set it also active, because this will be set automatically on login.
  member.locked = false
end

param.update(member, "identification", "notify_email", "admin")

-- trim input and return nil if empty
local function get_null(field)
  local value = param.get(field)
  if value then
    value = util.trim(value)
    if value == "" then
      return nil
    end
  end
  return value
end

member.login          = get_null("login")
member.name           = get_null("name")
member.identification = get_null("identification")

local err = member:try_save()
if err then
  slot.put_into("error", (_("Error while updating member, database reported:<br /><br /> (#{errormessage})"):gsub("#{errormessage}", tostring(err.message))))
  return false
end

-- privileges
if not id and config.single_unit_id then
  local privilege = Privilege:new()
  privilege.member_id = member.id
  privilege.unit_id = config.single_unit_id
  privilege.voting_right = true
  privilege:save()
end
local units = Unit:new_selector()
  :add_field("privilege.member_id NOTNULL", "privilege_exists")
  :add_field("privilege.voting_right", "voting_right")
  :left_join("privilege", nil, { "privilege.member_id = ? AND privilege.unit_id = unit.id", member.id })
  :exec()
for i, unit in ipairs(units) do
  local value = param.get("unit_" .. unit.id, atom.boolean)
  if value and not unit.privilege_exists then
    local privilege = Privilege:new()
    privilege.unit_id = unit.id
    privilege.member_id = member.id
    privilege.voting_right = true
    privilege:save()
  elseif not value and unit.privilege_exists then
    local privilege = Privilege:by_pk(unit.id, member.id)
    privilege:destroy()
  end
end

if not member.activated and param.get("invite_member", atom.boolean) then
  member:send_invitation()
end

if id then
  slot.put_into("notice", _"Member successfully updated")
else
  slot.put_into("notice", _"Member successfully registered")
end

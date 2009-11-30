if not app.session.member.admin then
  error('access denied')
end

local id = param.get_id()

local member

if id then
  member = Member:new_selector():add_where{"id = ?", id}:single_object_mode():exec()
else
  member = Member:new()
end

param.update(member, "login", "admin", "name", "active")

local password = param.get("password")
if password == "********" or #password == 0 then
  password = nil
end

if password then
  member:set_password(password)
end

local err = member:try_save()

if err then
  slot.put_into("error", (_("Error while updating member, database reported:<br /><br /> (#{errormessage})"):gsub("#{errormessage}", tostring(err.message))))
  return false
else
  if id then
    slot.put_into("notice", _"Member successfully updated")
  else
    slot.put_into("notice", _"Member successfully registered")
  end
end
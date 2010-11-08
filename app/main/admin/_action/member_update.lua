local member = Member:by_id(param.get_id()) or Member:new()

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
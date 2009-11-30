local member = app.session.member
local other_member = Member:by_id(param.get_id())

local public = param.get("public", atom.boolean)

local contact = Contact:by_pk(member.id, other_member.id)

if public == nil and contact then
  slot.put_into("error", _"Member is already saved in your contacts!")
  return false
end

if contact then
  contact:destroy()
end

contact = Contact:new()
contact.member_id = member.id
contact.other_member_id = other_member.id
contact.public = public or false
contact:save()

if public then
--  slot.put_into("notice", _"Member has been saved as public contact")
else
--  slot.put_into("notice", _"Member has been saved as private contact")
end

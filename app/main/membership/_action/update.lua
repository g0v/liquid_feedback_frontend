local area_id = assert(param.get("area_id", atom.integer), "no area id given")
local membership = Membership:by_pk(area_id, app.session.member.id)

if param.get("delete", atom.boolean) then
  if membership then
    membership:destroy()
    --slot.put_into("notice", _"Membership removed")
  else
    --slot.put_into("notice", _"Membership not existent")
  end
  return
end

if not membership then
  membership = Membership:new()
  membership.area_id    = area_id
  membership.member_id  = app.session.member_id
end

membership:save()

--slot.put_into("notice", _"Membership updated")

local issue_id = assert(param.get("issue_id", atom.integer), "no issue id given")
local interest = Interest:by_pk(issue_id, app.session.member.id)

if param.get("delete", atom.boolean) then
  if interest then
    interest:destroy()
    slot.put_into("notice", _"Interest removed")
  else
    slot.put_into("notice", _"Interest not existant")
  end
  return
end

if not interest then
  interest = Interest:new()
  interest.issue_id   = issue_id
  interest.member_id  = app.session.member_id
  interest.autoreject = false
end

local autoreject = param.get("autoreject", atom.boolean)
if autoreject ~= nil then
  interest.autoreject = autoreject
end

interest:save()

slot.put_into("notice", _"Interest updated")

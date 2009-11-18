local member_id = app.session.member.id

local suggestion_id = param.get("suggestion_id", atom.integer)

local opinion = Opinion:by_pk(member_id, suggestion_id)

if opinion and param.get("delete") then
  opinion:destroy()
  slot.put_into("notice", _"Your opinion has been updated")
  return
end

if not opinion then
  opinion = Opinion:new()
  opinion.member_id     = member_id
  opinion.suggestion_id = suggestion_id
  opinion.fulfilled     = false
end

local degree = param.get("degree", atom.number)
local fulfilled = param.get("fulfilled", atom.boolean)

if degree ~= nil then
  opinion.degree = degree
end

if fulfilled ~= nil then
  opinion.fulfilled = fulfilled
end

opinion:save()

slot.put_into("notice", _"Your opinion has been updated")

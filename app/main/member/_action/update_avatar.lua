local member_id = app.session.member_id

local member_image = MemberImage:by_pk(member_id, "avatar", false)
local member_image_scaled = MemberImage:by_pk(member_id, "avatar", true)

if param.get("avatar_delete", atom.boolean) then
  if member_image then
    member_image:destroy()
  end
  if member_image_scaled then
    member_image_scaled:destroy()
  end
  slot.put_into("notice", _"Avatar has been deleted")
  return
end

local data = param.get("avatar")

local data_scaled, err, status = os.pfilter(data, "convert", "-", "-thumbnail", "48x48", "-")

if status ~= 0 or data_scaled == nil then
 error("error while converting image")
end

if not member_image then
  member_image = MemberImage:new()
  member_image.member_id = member_id
  member_image.image_type = "avatar"
  member_image.scaled = false
  member_image.data = ""
  member_image:save()
end

if not member_image_scaled then
  member_image_scaled = MemberImage:new()
  member_image_scaled.member_id = member_id
  member_image_scaled.image_type = "avatar"
  member_image_scaled.scaled = true
  member_image_scaled.content_type = true
  member_image_scaled.data = ""
  member_image_scaled:save()
end

if data and #data > 0 then
  db:query{ "UPDATE member_image SET data = $ WHERE member_id = ? AND image_type='avatar' AND scaled=FALSE", { db:quote_binary(data) }, app.session.member.id }
end

if data_scaled and #data_scaled > 0 then
  db:query{ "UPDATE member_image SET data = $ WHERE member_id = ? AND image_type='avatar' AND scaled=TRUE", { db:quote_binary(data_scaled) }, app.session.member.id }
end

slot.put_into("notice", _"Avatar has been updated")

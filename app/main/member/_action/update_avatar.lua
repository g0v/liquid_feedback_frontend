local data = param.get("avatar")

if param.get("avatar_delete", atom.boolean) then
  app.session.member.avatar = nil
  app.session.member:save()
  slot.put_into("notice", _"Avatar has been deleted")
  return
end

local data, err, status = os.pfilter(data, "convert", "-", "-thumbnail", "48x48", "-")

if status ~= 0 or data == nil then
 error("error while converting image")
end

if data and #data > 0 then
  db:query{ 'UPDATE member SET avatar = $ WHERE id = ?', { db:quote_binary(data) }, app.session.member.id }
end

slot.put_into("notice", _"Avatar has been updated")

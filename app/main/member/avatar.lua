local record = MemberImage:by_pk(param.get_id(), "avatar", true)

if record == nil then
  print('Location: ' .. encode.url{ static = 'avatar.jpg' } .. '\n\n')
  exit()
end

print('Content-type: ' .. record.content_type .. '\n')

if record then
  io.stdout:write(record.data)
else
end

exit()

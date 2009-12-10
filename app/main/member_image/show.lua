local image_type = param.get("image_type")
local record = MemberImage:by_pk(param.get_id(), image_type, true)

if record == nil then
  local default_file = config.member_image_default_file[image_type]
  if default_file then
    print('Location: ' .. encode.url{ static = default_file } .. '\n\n')
  else
    print('Location: ' .. encode.url{ static = 'icons/16/lightning.png' } .. '\n\n')
  end
  exit()
end

print('Content-type: ' .. record.content_type .. '\n')

if record then
  io.stdout:write(record.data)
else
end

exit()

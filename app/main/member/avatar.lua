local record = Member:by_id(param.get_id())

if false and (not record or not record.avatar) then
  print('Location: ' .. encode.url{ static = 'no_image.png' } .. '\n\n')
  exit()
end

print('Content-type: image/jpg\n')

if record then
  io.stdout:write(record.avatar)
else
end

exit()

if not config.document_dir then
  error("feature not enabled")
end

local filename = param.get("filename")

local file = assert(io.open(encode.file_path(config.document_dir, filename)), "file not found")

print('Content-type: application/octet-stream')
print('Content-disposition: attachment; filename=' .. filename)
print('')

io.stdout:write(file:read("*a"))

exit()

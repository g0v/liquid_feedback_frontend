function util.trim(string)
  return (string:gsub("^%s*", ""):gsub("%s*$", ""):gsub("%s+", " "))
end
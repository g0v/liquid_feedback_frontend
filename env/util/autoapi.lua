function util.autoapi_xml(args)
  local selector = assert(args.selector)
  local fields = assert(args.fields)
  local rows = selector:exec()
  slot.set_layout("xml")
  slot.put("<initiative_list>\n")
  for i_row, row in ipairs(rows) do
    slot.put("  <initiative>\n")
    for i_field, field in ipairs(fields) do
      slot.put("    <", field.name, ">")
      local value
      if field.func then
        value = field.func(row)
      elseif field.field then
        value = row[field.name]
      end
      if value then
        slot.put(encode.html(tostring(value)))
      end
      slot.put("</", field.name, ">\n")
    end
    slot.put("  </initiative>\n")
  end
  slot.put("</initiative_list>\n")
end

function util.autoapi_json(args)
  slot.set_layout("blank")
  local selector = assert(args.selector)
  local fields = assert(args.fields)
  local rows = selector:exec()
  slot.put("{\n")
  for i_row, row in ipairs(rows) do
    slot.put("  {\n")
    for i_field, field in ipairs(fields) do
      slot.put("    ", field.name, ": ")
      local value
      if field.func then
        value = field.func(row)
      elseif field.field then
        value = row[field.name]
      end
        slot.put(encode.json(value))
      slot.put(",\n")
    end
    slot.put("  },\n")
  end
  slot.put("}\n")
end

function util.autoapi(args)
  local selector = assert(args.selector)
  local fields = assert(args.fields)
  local api_engine = assert(args.api_engine)

  selector:reset_fields()

  for i_field, field in ipairs(fields) do
    if field.field then
      selector:add_field(field.field, field.name)
    end
  end

  if api_engine == "xml" then
    util.autoapi_xml{
      selector = selector,
      fields = fields
    }
  elseif api_engine == "json" then
    util.autoapi_json{
      selector = selector,
      fields = fields
    }
  end

end
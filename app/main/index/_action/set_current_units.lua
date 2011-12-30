-- TODO support multiple units
local current_unit_id = param.get("unit_ids", atom.integer)

request.set_perm_param("units", current_unit_id)



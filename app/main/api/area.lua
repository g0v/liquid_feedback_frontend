local id     = param.get("id")
local min_id = param.get("min_id")
local max_id = param.get("max_id")
local order  = param.get("order")
local limit  = param.get("limit", atom.integer)

local areas_selector = Area:new_selector()

if id then
  areas_selector:add_where{"area.id = ?", id}
end

if min_id then
  areas_selector:add_where{"area.id >= ?", min_id}
end

if max_id then
  areas_selector:add_where{"area.id <= ?", max_id}
end

if order == "name" then
  areas_selector:add_order_by("area.name")
end

if order == "member_weight" then
  areas_selector:add_order_by("area.member_weight DESC")
end

areas_selector:add_order_by("area.id")

if limit then
  initiatives_selector:limit(limit)
end

local api_engine = param.get("api_engine") or "xml"

local fields = {

  { name = "id",                   field = "area.id" },
  { name = "name",                 field = "area.name" },
  { name = "description",          field = "area.description" },
  { name = "direct_member_count",  field = "area.direct_member_count" },
  { name = "member_weight",        field = "area.member_weight" },
  { name = "autoreject_weight",    field = "area.autoreject_weight" },
  { name = "active",               field = "area.active" },

}

util.autoapi{
  relation_name = "area",
  selector      = areas_selector,
  fields        = fields,
  api_engine    = api_engine
}
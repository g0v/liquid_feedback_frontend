local id     = param.get("id")
local min_id = param.get("min_id")
local max_id = param.get("max_id")
local initiative_id = param.get("initiative_id")
local order  = param.get("order")
local limit  = param.get("limit", atom.integer)

local suggestions_selector = Suggestion:new_selector()

if id then
  suggestions_selector:add_where{"suggestion.id = ?", id}
end

if min_id then
  suggestions_selector:add_where{"suggestion.id >= ?", min_id}
end

if max_id then
  suggestions_selector:add_where{"suggestion.id <= ?", max_id}
end

if initiative_id then
  suggestions_selector:add_where{"suggestion.initiative_id = ?", initiative_id}
end

if order == "id_desc" then
  suggestions_selector:add_order_by("suggestion.id DESC")
else
  suggestions_selector:add_order_by("suggestion.id")
end

if limit then
  suggestions_selector:limit(limit)
end

local api_engine = param.get("api_engine") or "xml"

local fields = {

  { name = "id",                       field = "suggestion.id" },
  { name = "initiative_id",            field = "suggestion.initiative_id" },
  { name = "name",                     field = "suggestion.name" },
  { name = "description",              field = "suggestion.description" },
  { name = "minus2_unfulfilled_count", field = "suggestion.minus2_unfulfilled_count" },
  { name = "minus2_fulfilled_count",   field = "suggestion.minus2_fulfilled_count" },
  { name = "minus1_unfulfilled_count", field = "suggestion.minus1_unfulfilled_count" },
  { name = "minus1_fulfilled_count",   field = "suggestion.minus1_fulfilled_count" },
  { name = "plus1_unfulfilled_count",  field = "suggestion.plus1_unfulfilled_count" },
  { name = "plus1_fulfilled_count",    field = "suggestion.plus1_fulfilled_count" },
  { name = "plus2_unfulfilled_count",  field = "suggestion.plus2_unfulfilled_count" },
  { name = "plus2_fulfilled_count",    field = "suggestion.plus2_fulfilled_count" },

}

util.autoapi{
  relation_name = "suggestion",
  selector      = suggestions_selector,
  fields        = fields,
  api_engine    = api_engine
}
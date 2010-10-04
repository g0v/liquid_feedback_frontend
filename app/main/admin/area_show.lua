local id = param.get_id()

local area
if id then
  area = Area:new_selector():add_where{ "id = ?", id }:single_object_mode():exec()
end

slot.put_into("title", _"Create new area")

ui.form{
  attr = { class = "vertical" },
  record = area,
  module = "admin",
  action = "area_update",
  routing = {
    default = {
      mode = "redirect",
      module = "admin",
      view = "area_list"
    }
  },
  id = area and area.id or nil,
  content = function()
    ui.field.text{    label = _"Name",        name = "name" }
    ui.field.boolean{ label = _"Active?",     name = "active" }
    ui.field.text{    label = _"Description", name = "description", multiline = true }
    ui.multiselect{   label = _"Policies",    name = "allowed_policies[]",
                      foreign_records = Policy:new_selector():add_where{ "active='t'"}:exec(),
                      foreign_id      = "id",
                      foreign_name    = "name",
                      connecting_records = area.allowed_policies,
                      foreign_reference  = "id" }
    ui.submit{ text = _"Save" }
  end
}

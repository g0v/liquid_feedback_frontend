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
    policies = Policy:new_selector():add_where{ "active='t'"}:exec()
    local def_policy = {
      {
        id = "-1",
        name = _"No default"
      }
    }
    for i, record in ipairs(policies) do
      def_policy[#def_policy+1] = record
    end

    ui.field.text{    label = _"Name",        name = "name" }
    ui.field.boolean{ label = _"Active?",     name = "active" }
    ui.field.text{    label = _"Description", name = "description", multiline = true }
    ui.field.select{   label = _"Default Policy",   name = "default_policy",
                 value=area.default_policy and area.default_policy.id or "-1",
                 foreign_records = def_policy,
                 foreign_id      = "id",
                 foreign_name    = "name"
    }
    ui.multiselect{   label = _"Policies",    name = "allowed_policies[]",
                      foreign_records = policies,
                      foreign_id      = "id",
                      foreign_name    = "name",
                      connecting_records = area.allowed_policies,
                      foreign_reference  = "id" }
    ui.submit{ text = _"Save" }
  end
}

local id = param.get_id()

local area = Area:by_id(id) or Area:new()

slot.put_into("title", _"Create / edit area")

slot.select("actions", function()
  ui.link{
    attr = { class = { "admin_only" } },
    text = _"Cancel",
    module = "admin",
    view = "area_list"
  }
end)

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
  id = id,
  content = function()
    policies = Policy:build_selector{ active = true }:exec()
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
    ui.field.select{  label = _"Default Policy",   name = "default_policy",
                 value=area.default_policy and area.default_policy.id or "-1",
                 foreign_records = def_policy,
                 foreign_id      = "id",
                 foreign_name    = "name"
    }
    ui.multiselect{   label = _"Policies",    name = "allowed_policies[]",
                      foreign_records = policies,
                      foreign_id      = "id",
                      foreign_name    = "name",
                      connecting_records = area.allowed_policies or {},
                      foreign_reference  = "id",
    }
    ui.submit{ text = _"Save" }
  end
}

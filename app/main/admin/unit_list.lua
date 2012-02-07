local units = Unit:get_flattened_tree{ active = true }

slot.put_into("title", _"Unit list")

slot.select("actions", function()
  ui.link{
    attr = { class = { "admin_only" } },
    text = _"Create new unit",
    module = "admin",
    view = "unit_edit"
  }
end)
 
ui.list{
  records = units,
  columns = {
    {
      label = "name",
      content = function(unit)
        ui.link{ text = unit.name, module = "admin", view = "area_list", params = { unit_id = unit.id } }
      end 
    }
  }
}
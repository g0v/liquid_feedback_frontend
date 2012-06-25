local units = Unit:get_flattened_tree{ active = true }

ui.title(_"Unit list")

ui.actions(function()
  ui.link{
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
      name = "name"
    },
    {
      content = function(unit)
        ui.link{
          text = _"Edit unit",
          module = "admin", view = "unit_edit", id = unit.id
        }
        slot.put(" ")
        ui.link{
          text = _"Edit areas",
          module = "admin", view = "area_list", params = { unit_id = unit.id }
        }
      end 
    }
  }
}
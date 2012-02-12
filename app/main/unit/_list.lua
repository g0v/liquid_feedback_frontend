local units = Unit:get_flattened_tree{ active = true }

ui.list{
  records = units,
  columns = {
    {
      content = function(unit)
        ui.link{ text = unit.name, module = "area", view = "list", params = { unit_id = unit.id } }
      end 
    }
  }
}
local units = Unit:get_flattened_tree{ active = true }

ui.list{
  records = units,
  columns = {
    {
      content = function(unit)
        for i = 1, unit.depth - 1 do
          slot.put("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;")
        end
        ui.link{ text = unit.name, module = "area", view = "list", params = { unit_id = unit.id } }
      end 
    }
  }
}
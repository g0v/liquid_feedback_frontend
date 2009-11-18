slot.put_into("title", _'Area list')

local areas_selector = Area:new_selector():add_where("active")

execute.view{
  module = "area",
  view = "_list",
  params = { areas_selector = areas_selector }
}

execute.view{
  module = "delegation",
  view = "_show_box"
}
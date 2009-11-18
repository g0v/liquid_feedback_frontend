local draft = Draft:new_selector():add_where{ "id = ?", param.get_id() }:single_object_mode():exec()

execute.view{
  module = "draft",
  view = "_show",
  params = { draft = draft }
}
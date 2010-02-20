local suggestion = Suggestion:by_id(param.get_id())

slot.put_into("title", encode.html(_"Suggestion for initiative: '#{name}'":gsub("#{name}", suggestion.initiative.name) ))

slot.select("actions", function()
  ui.link{
    content = function()
        ui.image{ static = "icons/16/resultset_previous.png" }
        slot.put(_"Back")
    end,
    module = "initiative",
    view = "show",
    id = suggestion.initiative.id,
    params = { tab = "suggestions" }
  }
end)

execute.view{
  module = "suggestion",
  view = "show_tab",
  params = {
    suggestion = suggestion
  }
}
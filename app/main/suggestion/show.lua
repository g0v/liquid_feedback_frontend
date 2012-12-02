local suggestion = Suggestion:by_id(param.get_id())

-- redirect to initiative if suggestion does not exist anymore
if not suggestion then
  local initiative_id = param.get('initiative_id', atom.integer)
  if initiative_id then
    slot.reset_all{except={"notice", "error"}}
    request.redirect{
      module='initiative',
      view='show',
      id=initiative_id,
      params = { tab = "suggestions" }
    }
  else
    slot.put_into('error', _"Suggestion does not exist anymore!")
  end
  return
end


app.html_title.title = suggestion.name
app.html_title.subtitle = _("Suggestion ##{id}", { id = suggestion.id })

ui.title(function()
  ui.link{
    content = suggestion.initiative.issue.area.unit.name,
    module = "unit",
    view = "show",
    id = suggestion.initiative.issue.area.unit.id
  }
  slot.put(" &middot; ")
  ui.link{
    content = suggestion.initiative.issue.area.name,
    module = "area",
    view = "show",
    id = suggestion.initiative.issue.area.id
  }
  slot.put(" &middot; ")
  ui.link{
    content = _("Issue ##{id}", { id = suggestion.initiative.issue.id }),
    module = "issue",
    view = "show",
    id = suggestion.initiative.issue.id
  }
  slot.put(" &middot; ")
  slot.put(_"Suggestion for" .. " ")
  ui.link{
    content = _("Initiative i#{id}: #{name}", { id = suggestion.initiative.id, name = suggestion.initiative.name }),
    module = "initiative",
    view = "show",
    id = suggestion.initiative.id
  }
end)

ui.actions(function()
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

local argument = Argument:by_id(param.get_id())

if not argument then
  slot.put_into('error', _"Argument does not exist!")
  return
end


app.html_title.title = argument.name
app.html_title.subtitle = _("Argument ##{id}", { id = argument.id })

ui.title(function()
  ui.link{
    content = argument.initiative.issue.area.unit.name,
    module = "unit",
    view = "show",
    id = argument.initiative.issue.area.unit.id
  }
  slot.put(" &middot; ")
  ui.link{
    content = argument.initiative.issue.area.name,
    module = "area",
    view = "show",
    id = argument.initiative.issue.area.id
  }
  slot.put(" &middot; ")
  ui.link{
    content = _("Issue ##{id}", { id = argument.initiative.issue.id }),
    module = "issue",
    view = "show",
    id = argument.initiative.issue.id
  }
  slot.put(" &middot; ")
  if argument.side == "pro" then
    slot.put(_"Argument pro for")
  else
    slot.put(_"Argument contra for")
  end
  slot.put(" ")
  ui.link{
    content = _("Initiative i#{id}: #{name}", { id = argument.initiative.id, name = argument.initiative.name }),
    module = "initiative",
    view = "show",
    id = argument.initiative.id
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
    id = argument.initiative.id,
    params = { tab = "arguments" }
  }
end)

execute.view{
  module = "argument",
  view = "show_tab",
  params = {
    argument = argument
  }
}

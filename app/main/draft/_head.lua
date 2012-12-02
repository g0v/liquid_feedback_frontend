local draft = param.get("draft", "table")
local initiative = draft.initiative
local issue = initiative.issue

local title = param.get("title")
app.html_title.title = title
app.html_title.subtitle = _("Initiative i#{id}", { id = initiative.id })

ui.title(function()
  ui.link{
    content = issue.area.unit.name,
    module = "unit",
    view = "show",
    id = issue.area.unit.id
  }
  slot.put(" &middot; ")
  ui.link{
    content = issue.area.name,
    module = "area",
    view = "show",
    id = issue.area.id
  }
  slot.put(" &middot; ")
  ui.link{
    content = issue.policy.name .. " #" .. issue.id,
    module = "issue",
    view = "show",
    id = issue.id
  }
  slot.put(" &middot; ")
  ui.link{
    content = _("Initiative i#{id}: #{name}", { id = initiative.id, name = initiative.name }),
    module = "initiative",
    view = "show",
    id = initiative.id
  }
  if title then
    slot.put(" &middot; ")
    ui.tag{
      content = title
    }
  end
end)

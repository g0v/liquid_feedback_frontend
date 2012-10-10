local draft = param.get("draft", "table")
local initiative = draft.initiative
local issue = initiative.issue

ui.title(function()
  ui.link{
    content = issue.area.name,
    module = "area",
    view = "show",
    id = issue.area.id
  }
  slot.put(" &middot; ")
  ui.link{
    content = _("Issue ##{id}", { id = issue.id }),
    module = "issue",
    view = "show",
    id = issue.id
  }
  slot.put(" &middot; ")
  ui.link{
    content = _("Initiative: ") .. initiative.name,
    module = "initiative",
    view = "show",
    id = initiative.id
  }
  local title = param.get("title")
  if title then
    slot.put(" &middot; ")
    ui.tag{
      content = title
    }    
  end
end)

local draft = param.get("draft", "table")
local initiative = draft.initiative
local issue = initiative.issue

local title = param.get("title")
app.html_title.title = title
app.html_title.subtitle = _("Initiative i#{id}", { id = initiative.id })

ui.title(title, issue.area.unit, issue.area, issue, initiative)

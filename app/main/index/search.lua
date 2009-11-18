local search_for = param.get("search_for", atom.string)
local search_string = param.get("search", atom.string)

search_for = search_for or "global"

slot.put_into("title", _("Search results for: '#{search}'", { search  = search_string }))


local members = {}
local issues = {}
local initiatives = {}


if search_for == "global" or search_for == "member" then
  members = Member:search(search_string)
end

if search_for == "global" or search_for == "issue" then
  issues = Issue:search(search_string)
end

if search_for == "initiative" then
  initiatives = Initiative:search(search_string)
end


if #members > 0 then
  ui.heading{ content = _"Members" }
  execute.view{
    module = "member",
    view = "_list",
    params = { members = members, highlight_string = search_string },
  }
end

if #issues > 0 then
  ui.heading{ content = _"Issues" }
  execute.view{
    module = "issue",
    view = "_list",
    params = { issues = issues, highlight_string = search_string },
  }
end

if #initiatives > 0 then
  ui.heading{ content = _"Initiatives" }
  execute.view{
    module = "initiative",
    view = "_list",
    params = { initiatives = initiatives, highlight_string = search_string },
  }
end


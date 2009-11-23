local search_for = param.get("search_for", atom.string)
local search_string = param.get("search", atom.string)

search_for = search_for or "global"

slot.put_into("title", _("Search results for: '#{search}'", { search  = search_string }))

if search_for == "global" or search_for == "member" then
  members_selector = Member:get_search_selector(search_string)
--if #members > 0 then
  ui.heading{ content = _"Members" }
  execute.view{
    module = "member",
    view = "_list",
    params = { members_selector = members_selector },
  }
--end
end

if search_for == "global" or search_for == "issue" then
  issues_selector = Issue:get_search_selector(search_string)
--if #issues > 0 then
  ui.heading{ content = _"Issues" }
  execute.view{
    module = "issue",
    view = "_list",
    params = { issues_selector = issues_selector, highlight_string = search_string },
  }
--end
end

if search_for == "initiative" then
  initiatives_selector = Initiative:get_search_selector(search_string)
--if #initiatives > 0 then
  ui.heading{ content = _"Initiatives" }
  execute.view{
    module = "initiative",
    view = "_list",
    params = { initiatives_selector = initiatives_selector },
  }
--end
end



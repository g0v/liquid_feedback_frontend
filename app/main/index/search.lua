local search_for = param.get("search_for", atom.string) or "global"
local search_string = param.get("search", atom.string)

slot.put_into("title", encode.html(_("Search results for: '#{search}'", { search  = search_string })))


if search_for == "global" or search_for == "member" then
  local members_selector = Member:get_search_selector(search_string)
  ui.heading{ content = _"Members" }
  execute.view{
    module = "member",
    view = "_list",
    params = { members_selector = members_selector },
  }
end

if search_for == "global" or search_for == "initiative" then
  local initiatives_selector = Initiative:get_search_selector(search_string)
  ui.heading{ content = _"Initiatives" }
  execute.view{
    module = "initiative",
    view = "_list",
    params = { initiatives_selector = initiatives_selector },
  }
end

if search_for == "issue" then
  local issues_selector = Issue:get_search_selector(search_string)
  ui.heading{ content = _"Issues" }
  execute.view{
    module = "issue",
    view = "_list",
    params = {
      issues_selector = issues_selector,
      highlight_string = search_string,
      no_filter = true
    },
  }
end



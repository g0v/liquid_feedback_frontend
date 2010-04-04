local area = param.get("area", "table") or Area:by_id(param.get("area_id", atom.integer))

local issues_selector = area:get_reference_selector("issues")
local members_selector = area:get_reference_selector("members")
local delegations_selector = area:get_reference_selector("delegations")

local tabs = {
  module = "area",
  view = "show_tab",
  static_params = { area_id = area.id },
}

tabs[#tabs+1] =
  {
    name = "issues",
    label = _"Issues" .. " (" .. tostring(issues_selector:count()) .. ")",
    icon = { static = "icons/16/folder.png" },
    module = "issue",
    view = "_list",
    params = {
      issues_selector = issues_selector,
      filter = cgi.params["filter"],
      filter_voting = param.get("filter_voting")
    }
  }

if app.session.member_id then
  tabs[#tabs+1] =
    {
      name = "members",
      label = _"Members" .. " (" .. tostring(members_selector:count()) .. ")",
      icon = { static = "icons/16/group.png" },
      module = "member",
      view = "_list",
      params = { members_selector = members_selector }
    }

  tabs[#tabs+1] =
    {
      name = "delegations",
      label = _"Delegations" .. " (" .. tostring(delegations_selector:count()) .. ")",
      icon = { static = "icons/16/table_go.png" },
      module = "delegation",
      view = "_list",
      params = { delegations_selector = delegations_selector }
    }
end

ui.tabs(tabs)

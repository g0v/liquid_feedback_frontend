local area = param.get("area", "table") or Area:by_id(param.get_id())

local open_issues_selector = area:get_reference_selector("issues")
  :add_where("issue.closed ISNULL")
  :add_order_by("coalesce(issue.fully_frozen + issue.voting_time, issue.half_frozen + issue.verification_time, issue.accepted + issue.discussion_time, issue.created + issue.admission_time) - now()")

local closed_issues_selector = area:get_reference_selector("issues")
  :add_where("issue.closed NOTNULL")
  :add_order_by("issue.closed DESC")

local members_selector = area:get_reference_selector("members")
local delegations_selector = area:get_reference_selector("delegations")

local tabs = {
  module = "area",
  view = "show_tab",
  static_params = { area_id = area.id },
}

tabs[#tabs+1] = {
  name = "timeline",
  label = _"Latest events",
  module = "event",
  view = "_list",
  params = { for_area = area }
}

tabs[#tabs+1] = {
  name = "open",
  label = _"Open issues",
  module = "issue",
  view = "_list",
  params = {
    for_state = "open",
    issues_selector = open_issues_selector, for_area = true
  }
}
tabs[#tabs+1] = {
  name = "closed",
  label = _"Closed issues",
  module = "issue",
  view = "_list",
  params = {
    for_state = "closed",
    issues_selector = closed_issues_selector, for_area = true
  }
}

if app.session.member_id then
  tabs[#tabs+1] =
    {
      name = "members",
      label = _"Participants" .. " (" .. tostring(members_selector:count()) .. ")",
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

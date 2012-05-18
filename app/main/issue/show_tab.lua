local issue
if request.get_json_request_slots() then
  issue = Issue:by_id(param.get("issue_id"))
else
  issue = param.get("issue", "table")
end

local interested_members_selector = issue:get_reference_selector("interested_members_snapshot")
  :join("issue", nil, "issue.id = direct_interest_snapshot.issue_id")
  :add_field("direct_interest_snapshot.weight")
  :add_where("direct_interest_snapshot.event = issue.latest_snapshot_event")

local delegations_selector = issue:get_reference_selector("delegations")

local tabs = {
  module = "issue",
  view = "show_tab",
  static_params = { issue_id = issue.id },
}

if app.session.member_id then
  tabs[#tabs+1] =
    {
      name = "interested_members",
      label = _"Interested" .. " (" .. tostring(interested_members_selector:count()) .. ")" ,
      module = "member",
      view = "_list",
      params = {
        issue = issue,
        members_selector = interested_members_selector
      }
    }

  tabs[#tabs+1] =
    {
      name = "delegations",
      label = _"Delegations" .. " (" .. tostring(delegations_selector:count()) .. ")" ,
      module = "delegation",
      view = "_list",
      params = { delegations_selector = delegations_selector }
    }
end

tabs[#tabs+1] =
  {
    name = "details",
    label = _"Details",
    module = "issue",
    view = "_details",
    params = { issue = issue }
  }
  
if config.etherpad then
  tabs[#tabs+1] =
    {
      name = "pad",
      label = _"Pad",
      module = "issue",
      view = "_pad",
      params = { issue = issue }
    }
end

ui.tabs(tabs)



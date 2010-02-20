local issue
if request.get_json_request_slots() then
  issue = Issue:by_id(param.get("issue_id"))
else
  issue = param.get("issue", "table")
end

local voting_requested_percentage = 0
if issue.vote_later and issue.population and issue.population > 0 then
  voting_requested_percentage = math.ceil(issue.vote_later  / issue.population * 100)
end

local interested_members_selector = issue:get_reference_selector("interested_members_snapshot")
  :join("issue", nil, "issue.id = direct_interest_snapshot.issue_id")
  :add_field("direct_interest_snapshot.weight")
  :add_where("direct_interest_snapshot.event = issue.latest_snapshot_event")

local voting_requests_selector = issue:get_reference_selector("interested_members_snapshot")
  :join("issue", nil, "issue.id = direct_interest_snapshot.issue_id")
  :add_where("direct_interest_snapshot.voting_requested = false")

local delegations_selector = issue:get_reference_selector("delegations")


ui.tabs{
  module = "issue",
  view = "show_tab",
  static_params = { issue_id = issue.id },
  {
    name = "interested_members",
    label = _"Interested members" .. " (" .. tostring(interested_members_selector:count()) .. ")" ,
    icon = { static = "icons/16/eye.png" },
    module = "member",
    view = "_list",
    params = {
      issue = issue,
      members_selector = interested_members_selector
    }
  },
  {
    name = "voting_requests",
    label = _"Vote later requests" .. " (" .. tostring(voting_requests_selector:count()) .. ") (" .. tostring(voting_requested_percentage) ..  "%)",
    icon = { static = "icons/16/clock_play.png" },
    module = "member",
    view = "_list",
    params = {
      issue = issue,
      members_selector = voting_requests_selector
    }
  },
  {
    name = "delegations",
    label = _"Delegations" .. " (" .. tostring(delegations_selector:count()) .. ")" ,
    icon = { static = "icons/16/table_go.png" },
    module = "delegation",
    view = "_list",
    params = { delegations_selector = delegations_selector }
  },
  {
    name = "details",
    label = _"Details",
    icon = { static = "icons/16/magnifier.png" },
    module = "issue",
    view = "_details",
    params = { issue = issue }
  },
}



local member

if request.get_json_request_slots() then
  member = Member:by_id(param.get("member_id"))
else
  member = param.get("member", "table")
end

local areas_selector = member:get_reference_selector("areas")
local issues_selector = member:get_reference_selector("issues")
local supported_initiatives_selector = member:get_reference_selector("supported_initiatives")
local initiated_initiatives_selector = member:get_reference_selector("initiated_initiatives"):add_where("initiator.accepted = true")
local incoming_delegations_selector = member:get_reference_selector("incoming_delegations")
  :left_join("issue", "_member_showtab_issue", "_member_showtab_issue.id = delegation.issue_id")
  :add_where("_member_showtab_issue.closed ISNULL")
local outgoing_delegations_selector = member:get_reference_selector("outgoing_delegations")
  :left_join("issue", "_member_showtab_issue", "_member_showtab_issue.id = delegation.issue_id")
  :add_where("_member_showtab_issue.closed ISNULL")
local contacts_selector = member:get_reference_selector("saved_members"):add_where("public")

ui.tabs{
  module = "member",
  view = "show_tab",
  static_params = { member_id = member.id },
  {
    name = "profile",
    label = _"Profile",
    icon = { static = "icons/16/application_form.png" },
    module = "member",
    view = "_profile",
    params = { member = member },
  },
  {
    name = "areas",
    label = _"Areas" .. " (" .. tostring(areas_selector:count()) .. ")",
    icon = { static = "icons/16/package.png" },
    module = "area",
    view = "_list",
    params = { areas_selector = areas_selector },
  },
  {
    name = "issues",
    label = _"Issues" .. " (" .. tostring(issues_selector:count()) .. ")",
    icon = { static = "icons/16/folder.png" },
    module = "issue",
    view = "_list",
    params = { issues_selector = issues_selector },
  },
  {
    name = "supported_initiatives",
    label = _"Supported initiatives" .. " (" .. tostring(supported_initiatives_selector:count()) .. ")",
    icon = { static = "icons/16/thumb_up_green.png" },
    module = "initiative",
    view = "_list",
    params = { initiatives_selector = supported_initiatives_selector },
  },
  {
    name = "initiatied_initiatives",
    label = _"Initiated initiatives" .. " (" .. tostring(initiated_initiatives_selector:count()) .. ")",
    icon = { static = "icons/16/user_edit.png" },
    module = "initiative",
    view = "_list",
    params = { initiatives_selector = initiated_initiatives_selector },
  },
  {
    name = "incoming_delegations",
    label = _"Incoming delegations" .. " (" .. tostring(incoming_delegations_selector:count()) .. ")",
    icon = { static = "icons/16/table_go.png" },
    module = "delegation",
    view = "_list",
    params = { delegations_selector = incoming_delegations_selector, incoming = true },
  },
  {
    name = "outgoing_delegations",
    label = _"Outgoing delegations" .. " (" .. tostring(outgoing_delegations_selector:count()) .. ")",
    icon = { static = "icons/16/table_go.png" },
    module = "delegation",
    view = "_list",
    params = { delegations_selector = outgoing_delegations_selector },
  },
  {
    name = "contacts",
    label = _"Contacts" .. " (" .. tostring(contacts_selector:count()) .. ")",
    icon = { static = "icons/16/book_edit.png" },
    module = "member",
    view = "_list",
    params = { members_selector = contacts_selector },
  }
}

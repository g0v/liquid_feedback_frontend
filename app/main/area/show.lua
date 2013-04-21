local area = Area:by_id(param.get_id())

if not area then
  slot.put_into("error", _"The requested area does not exist!")
  return
end

app.html_title.title = area.name
app.html_title.subtitle = _("Area")

util.help("area.show")

slot.select("head", function()
  execute.view{ module = "area", view = "_head", params = { area = area, show_content = true, member = app.session.member } }
end)

local open_issues_selector = area:get_reference_selector("issues")
  :add_where("issue.closed ISNULL")
  :add_order_by("coalesce(issue.fully_frozen + issue.voting_time, issue.half_frozen + issue.verification_time, issue.accepted + issue.discussion_time, issue.created + issue.admission_time) - now()")

local closed_issues_selector = area:get_reference_selector("issues")
  :add_where("issue.closed NOTNULL")
  :add_order_by("issue.closed DESC")

local tabs = {
  module = "area",
  view = "show_tab",
  static_params = { area_id = area.id },
}

tabs[#tabs+1] = {
  name = "open",
  label = _"Open issues",
  module = "issue",
  view = "_list",
  params = {
    for_state = "open",
    issues_selector = open_issues_selector,
    for_area = true
  }
}

tabs[#tabs+1] = {
  name = "closed",
  label = _"Closed issues",
  module = "issue",
  view = "_list",
  params = {
    for_state = "closed",
    issues_selector = closed_issues_selector,
    for_area = true
  }
}

tabs[#tabs+1] = {
  name = "timeline",
  label = _"Latest events",
  module = "event",
  view = "_list",
  params = {
    for_area = area
  }
}

if app.session:has_access("all_pseudonymous") then

  local members_selector = area:get_reference_selector("members")
    :add_where("member.active")
    :left_join("contact", nil, { "contact.other_member_id = member.id AND contact.member_id = ?", app.session.member_id })
    :add_field("contact.member_id NOTNULL", "saved")
  tabs[#tabs+1] = {
    name = "members",
    label = _"Participants" .. " (" .. tostring(members_selector:count()) .. ")",
    module = "member",
    view = "_list",
    params = { members_selector = members_selector }
  }

  if area.delegation then
    local delegations_selector = Member:new_selector()
      :reset_fields()
      :add_field("member.id", "member_id")
      :add_field("delegation.unit_id")
      :add_field("delegation.area_id")
      :add_field("delegation.issue_id")
      :join("delegation", "delegation", "member.id = delegation.truster_id")
      :join("member", "trustee", "trustee.id = delegation.trustee_id")
      :add_where{ "member.active" }
      :add_where{ "trustee.active" }
      :add_where{ "delegation.unit_id ISNULL" }
      :add_where{ "delegation.area_id = ?", area.id }
      :add_where{ "delegation.issue_id ISNULL" }
      :add_order_by("member.name")
      :add_group_by("member.name, member.id, delegation.unit_id, delegation.area_id, delegation.issue_id")
    tabs[#tabs+1] = {
      name = "delegations",
      label = _"Delegations" .. " (" .. tostring(delegations_selector:count()) .. ")",
      module = "delegation",
      view = "_list",
      params = { delegations_selector = delegations_selector }
    }
  end

end

ui.tabs(tabs)

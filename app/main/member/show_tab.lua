local show_as_homepage = param.get("show_as_homepage", atom.boolean)

local member

if request.get_json_request_slots() then
  member = Member:by_id(param.get("member_id"))
else
  member = param.get("member", "table")
end

local tabs = {
  module = "member",
  view = "show_tab",
  static_params = {
    member_id = member.id,
    show_as_homepage = show_as_homepage
  }
}

if show_as_homepage and app.session.member_id == member.id then

  if app.session.member.notify_email_unconfirmed then
    tabs[#tabs+1] = {
      class = "yellow",
      name = "email_unconfirmed",
      label = _"Email unconfirmed",
      icon = { static = "icons/16/bell.png" },
      module = "member",
      view = "_email_unconfirmed",
      params = {}
    }
  end

  if config.motd_intern then
    tabs[#tabs+1] = {
      class = "yellow",
      name = "motd",
      label = _"Message of the day",
      icon = { static = "icons/16/bell.png" },
      module = "index",
      view = "_motd",
      params = {}
    }
  end

  local broken_delegations = Delegation:new_selector()
    :join("issue", nil, "issue.id = delegation.issue_id AND issue.closed ISNULL")
    :join("member", nil, "delegation.trustee_id = member.id")
    :add_where{"delegation.truster_id = ?", member.id}
    :add_where{"member.active = 'f' OR (member.last_activity IS NULL OR age(member.last_activity) > ?::interval)", config.delegation_warning_time }

  if broken_delegations:count() > 0 then
    tabs[#tabs+1] = {
      class = "red",
      name = "broken_delegations",
      label = _"Delegation problems" .. " (" .. tostring(broken_delegations:count()) .. ")",
      icon = { static = "icons/16/table_go.png" },
      module = "delegation",
      view = "_list",
      params = { delegations_selector = broken_delegations, outgoing = true },
    }
  end

  local selector = Area:new_selector()
    :reset_fields()
    :add_field("area.id", nil, { "grouped" })
    :add_field("area.name", nil, { "grouped" })
    :add_field("membership.member_id NOTNULL", "is_member", { "grouped" })
    :add_field("count(issue.id)", "issues_to_vote_count")
    :add_field("count(interest.member_id)", "interested_issues_to_vote_count")
    :add_field("count(interest.member_id NOTNULL OR interest.member_id NOTNULL)", "issues_to_vote_count_sum")
    :join("issue", nil, "issue.area_id = area.id AND issue.fully_frozen NOTNULL AND issue.closed ISNULL")
    :left_join("direct_voter", nil, { "direct_voter.issue_id = issue.id AND direct_voter.member_id = ?", app.session.member.id })
    :add_where{ "direct_voter.member_id ISNULL" }
    :left_join("interest", nil, { "interest.issue_id = issue.id AND interest.member_id = ?", app.session.member.id })
    :left_join("membership", nil, { "membership.area_id = area.id AND membership.member_id = ? ", app.session.member.id })

  local not_voted_areas = {}
  local issues_to_vote_count = 0
  for i, area in ipairs(selector:exec()) do
    if area.is_member or area.interested_issues_to_vote_count > 0 then
      not_voted_areas[#not_voted_areas+1] = area
    end
    if area.is_member then
      issues_to_vote_count = issues_to_vote_count + area.issues_to_vote_count_sum
    end
  end

  if issues_to_vote_count > 0 then
    tabs[#tabs+1] = {
      class = "yellow",
      name = "not_voted_issues",
      label = _"Not voted issues" .. " (" .. tostring(issues_to_vote_count) .. ")",
      icon = { static = "icons/16/email_open.png" },
      module = "index",
      view = "_not_voted_issues",
      params = {
        areas = not_voted_areas
      }
    }
  end

  local initiator_invites_selector = Initiative:new_selector()
    :join("issue", "_issue_state", "_issue_state.id = initiative.issue_id")
    :join("initiator", nil, { "initiator.initiative_id = initiative.id AND initiator.member_id = ? AND initiator.accepted ISNULL", app.session.member.id })
    :add_where("_issue_state.closed ISNULL AND _issue_state.half_frozen ISNULL")

  if initiator_invites_selector:count() > 0 then
    tabs[#tabs+1] = {
      class = "yellow",
      name = "initiator_invites",
      label = _"Initiator invites" .. " (" .. tostring(initiator_invites_selector:count()) .. ")",
      icon = { static = "icons/16/user_add.png" },
      module = "index",
      view = "_initiator_invites",
      params = {
        initiatives_selector = initiator_invites_selector
      }
    }
  end

  local updated_drafts_selector = Initiative:new_selector()
    :join("issue", "_issue_state", "_issue_state.id = initiative.issue_id AND _issue_state.closed ISNULL AND _issue_state.fully_frozen ISNULL")
    :join("current_draft", "_current_draft", "_current_draft.initiative_id = initiative.id")
    :join("supporter", "supporter", { "supporter.member_id = ? AND supporter.initiative_id = initiative.id AND supporter.draft_id < _current_draft.id", app.session.member_id })
    :add_where("initiative.revoked ISNULL")

  if updated_drafts_selector:count() > 0 then
    tabs[#tabs+1] = {
      class = "yellow",
      name = "updated_drafts",
      label = _"Updated drafts" .. " (" .. tostring(updated_drafts_selector:count()) .. ")",
      icon = { static = "icons/16/script.png" },
      module = "index",
      view = "_updated_drafts",
      params = {
        initiatives_selector = updated_drafts_selector
      }
    }
  end
end

if not show_as_homepage then
  tabs[#tabs+1] = {
    name = "profile",
    label = _"Profile",
    icon = { static = "icons/16/application_form.png" },
    module = "member",
    view = "_profile",
    params = { member = member },
  }
end

local areas_selector = member:get_reference_selector("areas")
tabs[#tabs+1] = {
  name = "areas",
  label = _"Areas",
  icon = { static = "icons/16/package.png" },
  module = "member",
  view = "_area_list",
  params = { areas_selector = areas_selector, member = member },
}

local issues_selector = Issue:new_selector()
tabs[#tabs+1] = {
  name = "issues",
  label = _"Issues",
  icon = { static = "icons/16/folder.png" },
  module = "issue",
  view = "_list",
  params = { issues_selector = issues_selector },
}
  
local outgoing_delegations_selector = member:get_reference_selector("outgoing_delegations")
  :left_join("issue", "_member_showtab_issue", "_member_showtab_issue.id = delegation.issue_id")
  :add_where("_member_showtab_issue.closed ISNULL")
tabs[#tabs+1] = {
  name = "outgoing_delegations",
  label = _"Outgoing delegations" .. " (" .. tostring(outgoing_delegations_selector:count()) .. ")",
  icon = { static = "icons/16/table_go.png" },
  module = "delegation",
  view = "_list",
  params = { delegations_selector = outgoing_delegations_selector, outgoing = true },
}

local incoming_delegations_selector = member:get_reference_selector("incoming_delegations")
  :left_join("issue", "_member_showtab_issue", "_member_showtab_issue.id = delegation.issue_id")
  :add_where("_member_showtab_issue.closed ISNULL")
tabs[#tabs+1] = {
  name = "incoming_delegations",
  label = _"Incoming delegations" .. " (" .. tostring(incoming_delegations_selector:count()) .. ")",
  icon = { static = "icons/16/table_go.png" },
  module = "delegation",
  view = "_list",
  params = { delegations_selector = incoming_delegations_selector, incoming = true },
}

local contacts_selector = member:get_reference_selector("saved_members"):add_where("public")
tabs[#tabs+1] = {
  name = "contacts",
  label = _"Contacts" .. " (" .. tostring(contacts_selector:count()) .. ")",
  icon = { static = "icons/16/book_edit.png" },
  module = "member",
  view = "_list",
  params = { members_selector = contacts_selector },
}

if show_as_homepage then
  tabs[#tabs+1] = {
    name = "profile",
    label = _"Profile",
    icon = { static = "icons/16/application_form.png" },
    module = "member",
    view = "_profile",
    params = { member = member },
  }
end

ui.tabs(tabs)

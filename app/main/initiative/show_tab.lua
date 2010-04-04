local initiative = param.get("initiative", "table")
local initiator = param.get("initiator", "table")

if not initiative then
  initiative = Initiative:by_id(param.get("initiative_id", atom.number))
end

if not initiator and app.session.member_id then
  initiator = Initiator:by_pk(initiative.id, app.session.member.id)
end

local current_draft_name = _"Current draft"
if initiative.issue.half_frozen then
  current_draft_name = _"Voting proposal"
end

if initiative.issue.state == "finished" then
  current_draft_name = _"Voted proposal"
end

local tabs = {
  {
    name = "current_draft",
    label = current_draft_name,
    icon = { static = "icons/16/script.png" },
    module = "initiative",
    view = "_current_draft",
    params = {
      initiative = initiative,
      initiator = initiator
    }
  }
}

if app.session.member_id then
  if initiative.issue.ranks_available then
    tabs[#tabs+1] = {
      name = "voting",
      label = _"Voting details",
      icon = { static = "icons/16/email_open.png" },
      module = "initiative",
      view = "_show_voting",
      params = {
        initiative = initiative
      }
    }
  end
end

local suggestion_count = initiative:get_reference_selector("suggestions"):count()

tabs[#tabs+1] = {
  name = "suggestions",
  label = _"Suggestions" .. " (" .. tostring(suggestion_count) .. ")",
  icon = { static = "icons/16/comments.png" },
  module = "initiative",
  view = "_suggestions",
  params = {
    initiative = initiative
  }
}

if app.session.member_id then
  local members_selector = initiative:get_reference_selector("supporting_members_snapshot")
            :join("issue", nil, "issue.id = direct_supporter_snapshot.issue_id")
            :join("direct_interest_snapshot", nil, "direct_interest_snapshot.event = issue.latest_snapshot_event AND direct_interest_snapshot.issue_id = issue.id AND direct_interest_snapshot.member_id = member.id")
            :add_field("direct_interest_snapshot.weight")
            :add_where("direct_supporter_snapshot.event = issue.latest_snapshot_event")
            :add_where("direct_supporter_snapshot.satisfied")
            :add_field("direct_supporter_snapshot.informed", "is_informed")
  
  local tmp = db:query("SELECT count(1) AS count, sum(weight) AS weight FROM (" .. tostring(members_selector) .. ") as subquery", "object")
  local direct_satisfied_supporter_count = tmp.count
  local indirect_satisfied_supporter_count = (tmp.weight or 0) - tmp.count
  
  local count_string
  if indirect_satisfied_supporter_count > 0 then
    count_string = "(" .. tostring(direct_satisfied_supporter_count) .. "+" .. tostring(indirect_satisfied_supporter_count) .. ")"
  else
    count_string = "(" .. tostring(direct_satisfied_supporter_count) .. ")"
  end
  
  tabs[#tabs+1] = {
    name = "satisfied_supporter",
    label = _"Supporter" .. " " .. count_string,
    icon = { static = "icons/16/thumb_up_green.png" },
    module = "member",
    view = "_list",
    params = {
      initiative = initiative,
      members_selector = members_selector
    }
  }
  
  local members_selector = initiative:get_reference_selector("supporting_members_snapshot")
            :join("issue", nil, "issue.id = direct_supporter_snapshot.issue_id")
            :join("direct_interest_snapshot", nil, "direct_interest_snapshot.event = issue.latest_snapshot_event AND direct_interest_snapshot.issue_id = issue.id AND direct_interest_snapshot.member_id = member.id")
            :add_field("direct_interest_snapshot.weight")
            :add_where("direct_supporter_snapshot.event = issue.latest_snapshot_event")
            :add_where("NOT direct_supporter_snapshot.satisfied")
            :add_field("direct_supporter_snapshot.informed", "is_informed")
  
  local tmp = db:query("SELECT count(1) AS count, sum(weight) AS weight FROM (" .. tostring(members_selector) .. ") as subquery", "object")
  local direct_potential_supporter_count = tmp.count
  local indirect_potential_supporter_count = (tmp.weight or 0) - tmp.count
  
  local count_string
  if indirect_potential_supporter_count > 0 then
    count_string = "(" .. tostring(direct_potential_supporter_count) .. "+" .. tostring(indirect_potential_supporter_count) .. ")"
  else
    count_string = "(" .. tostring(direct_potential_supporter_count) .. ")"
  end
  
  tabs[#tabs+1] = {
    name = "supporter",
    label = _"Potential supporter" .. " " .. count_string,
    icon = { static = "icons/16/thumb_up.png" },
    module = "member",
    view = "_list",
    params = {
      initiative = initiative,
      members_selector = members_selector
    }
  }
  
  local initiators_members_selector = initiative:get_reference_selector("initiating_members")
    :add_field("initiator.accepted", "accepted")
  
  if not (initiator and initiator.accepted) then
    initiators_members_selector:add_where("initiator.accepted")
  end
  
  local initiator_count = initiators_members_selector:count()
  
  tabs[#tabs+1] = {
    name = "initiators",
    label = _"Initiators" .. " (" .. tostring(initiator_count) .. ")",
    icon = { static = "icons/16/user_edit.png" },
    module = "initiative",
    view = "_initiators",
    params = {
      initiative = initiative,
      initiator = initiator,
      initiators_members_selector = initiators_members_selector
    }
  }
end

local drafts_count = initiative:get_reference_selector("drafts"):count()

tabs[#tabs+1] = {
  name = "drafts",
  label = _"Draft history" .. " (" .. tostring(drafts_count) .. ")",
  icon = { static = "icons/16/script.png" },
  module = "draft",
  view = "_list",
  params = { drafts = initiative.drafts }
}

tabs[#tabs+1] = {
  name = "details",
  label = _"Details",
  icon = { static = "icons/16/magnifier.png" },
  module = "initiative",
  view = "_details",
  params = {
    initiative = initiative,
    members_selector = members_selector
  }
}

tabs.module = "initiative"
tabs.view = "show_tab"
tabs.static_params = {
  initiative_id = initiative.id
}

ui.tabs(tabs)


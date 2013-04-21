local notification_links = {}

if app.session.member.notify_email_unconfirmed then
  notification_links[#notification_links+1] = {
    module = "index", view = "email_unconfirmed",
    text = _"Please confirm your email address!"
  }
end

if app.session.member.notify_level == nil then
  notification_links[#notification_links+1] = {
    module = "member", view = "settings_notification",
    text = _"Please select your preferred notification level!"
  }
end

local expiring_delegations_selector = Delegation:new_selector()
  :optional_object_mode()
  :add_where("delegation.issue_id ISNULL")
  :add_where{"delegation.truster_id = ?", app.session.member_id}
  :add_group_by("delegation.id")
if config.delegation_warning_time then
  expiring_delegations_selector:add_field("count(1)", "count")
    :add_field("count(CASE WHEN delegation.active = FALSE THEN 1 ELSE NULL END)", "expired_count")
    :left_join("system_setting", nil, "TRUE")
    :add_field(
      "justify_interval(age(MIN(delegation.confirmed), CURRENT_DATE) + system_setting.delegation_ttl)",
      "time_left"
    )
    :add_where{
      "delegation.active = FALSE OR delegation.confirmed < (CURRENT_DATE - (system_setting.delegation_ttl - ?::interval))::DATE",
      config.delegation_warning_time
    }
    :add_group_by("system_setting.delegation_ttl")
else
  expiring_delegations_selector:add_field("count(1)", "expired_count")
    :add_where("delegation.active = FALSE")
end
local expiring_delegations = expiring_delegations_selector:exec()
if expiring_delegations then
  local text
  if expiring_delegations.expired_count == 0 then
    if expiring_delegations.count == 1 then
      text = format.interval_text(
        expiring_delegations.time_left, { mode = "expires", variant = "warning_one" }
      )
    else
      text = format.interval_text(
        expiring_delegations.time_left, { mode = "expires", variant = "warning_multiple", count = expiring_delegations.count }
      )
    end
  else
    if expiring_delegations.expired_count == 1 then
      text = _("One of your outgoing delegations is expired.")
    else
      text = _("#{count} of your outgoing delegations are expired.", { count = expiring_delegations.expired_count })
    end
  end
  notification_links[#notification_links+1] = {
    module = "index", view = "expiring_delegations",
    text = text
  }
end

local broken_delegations_count = Delegation:new_selector()
  :left_join("issue", nil, "issue.id = delegation.issue_id")
  :add_where("issue.closed ISNULL")
  :join("member", nil, "delegation.trustee_id = member.id")
  :add_where{"delegation.truster_id = ?", member_id}
  :add_where("member.active = FALSE")
  :count()
if broken_delegations_count > 0 then
  if broken_delegations_count == 1 then
    text = _"One of your outgoing delegations is broken."
  else
    text = _("#{count} of your outgoing delegations are broken.", { count = broken_delegations_count })
  end
  notification_links[#notification_links+1] = {
    module = "index", view = "broken_delegations",
    text = text
  }
end

local issues_to_vote_count = Issue:new_selector()
  :join("area", nil, "area.id = issue.area_id")
  :join("privilege", nil, { "privilege.unit_id = area.unit_id AND privilege.member_id = ? AND privilege.voting_right", app.session.member_id })
  :left_join("direct_voter", nil, { "direct_voter.issue_id = issue.id AND direct_voter.member_id = ?", app.session.member.id })
  :left_join("non_voter", nil, { "non_voter.issue_id = issue.id AND non_voter.member_id = ?", app.session.member.id })
  :left_join("interest", nil, { "interest.issue_id = issue.id AND interest.member_id = ?", app.session.member.id })
  :add_where{ "direct_voter.member_id ISNULL" }
  :add_where{ "non_voter.member_id ISNULL" }
  :add_where{ "interest.member_id NOTNULL" }
  :add_where{ "issue.fully_frozen NOTNULL" }
  :add_where{ "issue.closed ISNULL" }
  :count()
if issues_to_vote_count > 0 then
  local text
  if issues_to_vote_count == 1 then
    text = _"You have not voted one issue you were interested in."
  else
    text = _("You have not voted #{count} issues you were interested in.", { count = issues_to_vote_count })
  end
  notification_links[#notification_links+1] = {
    module = "index", view = "index",
    params = {
      tab = "open", filter = "frozen", filter_interest = "issue", filter_delegation = "direct", filter_voting = "not_voted"
    },
    text = text
  }
end

local initiator_invites_count = Initiator:selector_for_invites(app.session.member_id):count()
if initiator_invites_count > 0 then
  local text
  if initiator_invites_count == 1 then
    text = _"You are invited to one initiative."
  else
    text = _("You are invited to #{count} initiatives.", { count = initiator_invites_count })
  end
  notification_links[#notification_links+1] = {
    module = "index", view = "initiator_invites",
    text = text
  }
end

updated_drafts_count = Initiative:selector_for_updated_drafts(app.session.member_id):count()
if updated_drafts_count > 0 then
  local text
  if updated_drafts_count == 1 then
    text = _"New draft for one initiative you are supporting"
  else
    text = _("New drafts for #{count} initiatives you are supporting", { count = updated_drafts_count })
  end
  notification_links[#notification_links+1] = {
    module = "index", view = "updated_drafts",
    text = text
  }
end

if #notification_links > 0 then
  ui.container{ attr = { class = "notifications" }, content = function()
    ui.tag{ tag = "ul", attr = { class = "notifications" }, content = function()
      for i, notification_link in ipairs(notification_links) do
        ui.tag{ tag = "li", content = function()
          ui.link(notification_link)
        end }
      end
    end }
  end }
end

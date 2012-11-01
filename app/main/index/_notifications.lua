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

local broken_delegations_count = Delegation:selector_for_broken(app.session.member_id):count()
if broken_delegations_count > 0 then
  if broken_delegations_count == 1 then
    text = _"One outgoing delegation is broken."
  else
    text = _("#{count} of your outgoing delegations are broken.", { count = broken_delegations_count })
  end
  notification_links[#notification_links+1] = {
    module = "index", view = "broken_delegations",
    text = text
  }
end

local selector = Issue:new_selector()
  :join("area", nil, "area.id = issue.area_id")
  :join("privilege", nil, { "privilege.unit_id = area.unit_id AND privilege.member_id = ? AND privilege.voting_right", app.session.member_id })
  :left_join("direct_voter", nil, { "direct_voter.issue_id = issue.id AND direct_voter.member_id = ?", app.session.member.id })
  :left_join("interest", nil, { "interest.issue_id = issue.id AND interest.member_id = ?", app.session.member.id })
  :add_where{ "direct_voter.member_id ISNULL" }
  :add_where{ "interest.member_id NOTNULL" }
  :add_where{ "issue.fully_frozen NOTNULL" }
  :add_where{ "issue.closed ISNULL" }
  :add_order_by{ "issue.fully_frozen + issue.voting_time ASC" }

local issues_to_vote_count = selector:count()
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

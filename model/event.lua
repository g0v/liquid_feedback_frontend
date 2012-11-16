Event = mondelefant.new_class()
Event.table = 'event'

Event:add_reference{
  mode          = 'm1',
  to            = "Issue",
  this_key      = 'issue_id',
  that_key      = 'id',
  ref           = 'issue',
}

Event:add_reference{
  mode          = 'm1',
  to            = "Initiative",
  this_key      = 'initiative_id',
  that_key      = 'id',
  ref           = 'initiative',
}

Event:add_reference{
  mode          = 'm1',
  to            = "Draft",
  this_key      = 'draft_id',
  that_key      = 'id',
  ref           = 'draft',
}

Event:add_reference{
  mode          = 'm1',
  to            = "Suggestion",
  this_key      = 'suggestion_id',
  that_key      = 'id',
  ref           = 'suggestion',
}

Event:add_reference{
  mode          = 'm1',
  to            = "Member",
  this_key      = 'member_id',
  that_key      = 'id',
  ref           = 'member',
}

function Event.object_get:event_name()
  return ({
    issue_state_changed = _"Issue reached next phase",
    initiative_created_in_new_issue = _"New issue",
    initiative_created_in_existing_issue = _"New initiative",
    initiative_revoked = _"Initiative revoked",
    new_draft_created = _"New initiative draft",
    suggestion_created = _"New suggestion"
  })[self.event]
end

function Event.object_get:state_name()
  return ({
    admission = _"New",
    discussion = _"Discussion",
    verification = _"Frozen",
    voting = _"Voting",
    canceled_revoked_before_accepted = _"Cancelled (before accepted due to revocation)",
    canceled_issue_not_accepted = _"Cancelled (issue not accepted)",
    canceled_after_revocation_during_discussion = _"Cancelled (during discussion due to revocation)",
    canceled_after_revocation_during_verification = _"Cancelled (during verification due to revocation)",
    calculation = _"Calculation",
    canceled_no_initiative_admitted = _"Cancelled (no initiative admitted)",
    finished_without_winner = _"Finished (without winner)",
    finished_with_winner = _"Finished (with winner)"
  })[self.state]
end

function Event.object:send_notification()

  local members_to_notify = Member:new_selector()
    :join("event_seen_by_member", nil, { "event_seen_by_member.seen_by_member_id = member.id AND event_seen_by_member.id = ?", self.id } )
    :add_where("member.activated NOTNULL AND member.notify_email NOTNULL")
    -- SAFETY FIRST, NEVER send notifications for events more then 3 days in past or future
    :add_where("now() - event_seen_by_member.occurrence BETWEEN '-3 days'::interval AND '3 days'::interval")
    -- do not notify a member about the events caused by the member
    :add_where("event_seen_by_member.member_id ISNULL OR event_seen_by_member.member_id != member.id")
    :exec()

  print ( "Event " .. self.id .. " -> " .. #members_to_notify .. " members" )


  local url

  for i, member in ipairs(members_to_notify) do
    local subject
    local body = ""

    locale.do_with(
      { lang = member.lang or config.default_lang or 'en' },
      function()

        -- url
        if self.suggestion_id then
          url = request.get_absolute_baseurl() .. "suggestion/show/" .. self.suggestion_id .. ".html"
        elseif self.initiative_id then
          url = request.get_absolute_baseurl() .. "initiative/show/" .. self.initiative_id .. ".html"
        else
          url = request.get_absolute_baseurl() .. "issue/show/" .. self.issue_id .. ".html"
        end
        body = body .. url .. "\n\n"

        -- head
        body = body .. _("[event mail]      Unit: #{name}", { name = self.issue.area.unit.name }) .. "\n"
        body = body .. _("[event mail]      Area: #{name}", { name = self.issue.area.name }) .. "\n"
        body = body .. _("[event mail]     Issue: #{policy} ##{id}", { policy = self.issue.policy.name, id = self.issue_id }) .. "\n\n"
        body = body .. _("[event mail]     Event: #{event}", { event = self.event_name }) .. "\n"
        body = body .. _("[event mail]     Phase: #{phase}", { phase = self.state_name }) .. "\n\n"

        local initiative
        if self.initiative_id then
          -- initiative
          initiative = Initiative:by_id(self.initiative_id)
          body = body .. _("i#{id}: #{name}", { id = initiative.id, name = initiative.name }) .. "\n\n"
        else
          -- initiatives of an issue
          local initiative_count = Initiative:new_selector()
            :add_where{ "initiative.issue_id = ?", self.issue_id }
            :count()
          local initiatives = Initiative:new_selector()
            :add_where{ "initiative.issue_id = ?", self.issue_id }
            :add_order_by("initiative.supporter_count DESC")
            :limit(3)
            :exec()
          for i, initiative in ipairs(initiatives) do
            body = body .. _("i#{id}: #{name}", { id = initiative.id, name = initiative.name }) .. "\n"
          end
          if initiative_count - 3 > 0 then
            body = body .. _("and #{count} more initiatives", { count = initiative_count - 3 }) .. "\n"
          end
          body = body .. "\n"
        end

        -- draft
        local draft
        if self.draft_id then
          draft = Draft:by_id(self.draft_id)
          body = body .. draft.content .. "\n"
        end

        -- suggestion
        local suggestion
        if self.suggestion_id then
          suggestion = Suggestion:by_id(self.suggestion_id)
          body = body .. _("Suggestion") .. ": " .. suggestion.name .. "\n\n"
          body = body .. suggestion.content .. "\n"
        end

        -- subject
        subject = config.mail_subject_prefix .. " "
        if self.event == "issue_state_changed" then
          if     self.state == "discussion" then
            subject = subject .. _("Issue ##{id} reached discussion", { id = self.issue_id })
          elseif self.state == "verification" then
            subject = subject .. _("Issue ##{id} was frozen", { id = self.issue_id })
          elseif self.state == "voting" then
            subject = subject .. _("Voting for issue ##{id} started", { id = self.issue_id })
          elseif self.state == "canceled_revoked_before_accepted" then
            subject = subject .. _("Issue ##{id} was cancelled due to revocation", { id = self.issue_id })
          elseif self.state == "canceled_issue_not_accepted" then
            subject = subject .. _("Issue ##{id} was not accepted", { id = self.issue_id })
          elseif self.state == "canceled_after_revocation_during_discussion" then
            subject = subject .. _("Issue ##{id} was cancelled due to revocation", { id = self.issue_id })
          elseif self.state == "canceled_after_revocation_during_verification" then
            subject = subject .. _("Issue ##{id} was cancelled due to revocation", { id = self.issue_id })
          elseif self.state == "canceled_no_initiative_admitted" then
            subject = subject .. _("Issue ##{id} was cancelled because no initiative was admitted", { id = self.issue_id })
          elseif self.state == "finished_without_winner" then
            subject = subject .. _("Issue ##{id} was finished (without winner)", { id = self.issue_id })
          elseif self.state == "finished_with_winner" then
            subject = subject .. _("Issue ##{id} was finished (with winner)", { id = self.issue_id })
          end
        elseif self.event == "initiative_created_in_new_issue" then
          subject = subject .. _("New issue ##{id} and initiative - i#{ini_id}: #{ini_name}", { id = self.issue_id, ini_id = initiative.id, ini_name = initiative.name })
        elseif self.event == "initiative_created_in_existing_issue" then
          subject = subject .. _("New initiative in issue ##{id} - i#{ini_id}: #{ini_name}", { id = self.issue_id, ini_id = initiative.id, ini_name = initiative.name })
        elseif self.event == "initiative_revoked" then
          subject = subject .. _("Initiative revoked - i#{id}: #{name}", { id = initiative.id, name = initiative.name })
        elseif self.event == "new_draft_created" then
          subject = subject .. _("New draft for initiative i#{id} - #{name}", { id = initiative.id, name = initiative.name })
        elseif self.event == "suggestion_created" then
          subject = subject .. _("New suggestion for initiative i#{id} - #{suggestion}", { id = initiative.id, suggestion = suggestion.name })
        end

        -- send mail
        local success = net.send_mail{
          envelope_from = config.mail_envelope_from,
          from          = config.mail_from,
          reply_to      = config.mail_reply_to,
          to            = member.notify_email,
          subject       = subject,
          content_type  = "text/plain; charset=UTF-8",
          content       = body
        }

      end
    )
  end

end

function Event:send_next_notification()

  local notification_sent = NotificationSent:new_selector()
    :optional_object_mode()
    :for_update()
    :exec()

  local last_event_id = 0
  if notification_sent then
    last_event_id = notification_sent.event_id
  end

  local event = Event:new_selector()
    :add_where{ "event.id > ?", last_event_id }
    :add_order_by("event.id")
    :limit(1)
    :optional_object_mode()
    :exec()

  if event then
    if last_event_id == 0 then
      db:query{ "INSERT INTO notification_sent (event_id) VALUES (?)", event.id }
    else
      db:query{ "UPDATE notification_sent SET event_id = ?", event.id }
    end

    event:send_notification()

    return true

  end

end

function Event:send_notifications()

  while true do
    local did_work = Event:send_next_notification()
    if not did_work then
      break
    end
  end

end
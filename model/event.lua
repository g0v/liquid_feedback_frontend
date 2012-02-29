Event = mondelefant.new_class()
Event.table = 'event'

Event:add_reference{
  mode          = 'm1',
  to            = "Issue",
  this_key      = 'issue_id',
  that_key      = 'id',
  ref           = 'issue',
}

function Event.object:send_notification() 

  local members_to_notify = Member:new_selector()
    :join("event_seen_by_member", nil, { "event_seen_by_member.seen_by_member_id = member.id AND event_seen_by_member.notify_level <= member.notify_level AND event_seen_by_member.id = ?", self.id } )
    :add_where("member.activated NOTNULL AND member.notify_email NOTNULL")
    :exec()
    
  print (_("Event #{id} -> #{num} members", { id = self.id, num = #members_to_notify }))


  local url

  local body = ""
  
  body = body .. _("      Unit: #{name}\n", { name = self.issue.area.unit.name })
  body = body .. _("      Area: #{name}\n", { name = self.issue.area.name })
  body = body .. _("     Issue: ##{id}\n", { id = self.issue_id })
  body = body .. _("    Policy: #{phase}\n", { phase = self.issue.policy.name })
  body = body .. _("     Phase: #{phase}\n\n", { phase = self.state })
  body = body .. _("     Event: #{event}\n\n", { event = self.event })

  if self.initiative_id then
    url = request.get_absolute_baseurl() .. "initiative/show/" .. self.initiative_id .. ".html"
  elseif self.suggestion_id then
    url = request.get_absolute_baseurl() .. "suggestion/show/" .. self.suggestion_id .. ".html"
  else
    url = request.get_absolute_baseurl() .. "issue/show/" .. self.issue_id .. ".html"
  end
  
  body = body .. _("       URL: #{url}\n\n", { url = url })
  
  if self.initiative_id then
    local initiative = Initiative:by_id(self.initiative_id)
    body = body .. _("i#{id}: #{name}\n\n", { id = initiative.id, name = initiative.name })
  else
    local initiative_count = Initiative:new_selector()
      :add_where{ "initiative.issue_id = ?", self.issue_id }
      :count()
    local initiatives = Initiative:new_selector()
      :add_where{ "initiative.issue_id = ?", self.issue_id }
      :add_order_by("initiative.supporter_count DESC")
      :limit(3)
      :exec()
    for i, initiative in ipairs(initiatives) do
      body = body .. _("i#{id}: #{name}\n", { id = initiative.id, name = initiative.name })
    end
    if initiative_count - 3 > 0 then
      body = body .. _("and #{count} more initiatives\n", { count = initiative_count })
    end
    body = body .. "\n"
  end
  
  if self.suggestion_id then
    local suggestion = Suggestion:by_id(self.suggestion_id)
    body = body .. _("#{name}\n\n", { name = suggestion.name })
  end
  
  for i, member in ipairs(members_to_notify) do
    local success = net.send_mail{
      envelope_from = config.mail_envelope_from,
      from          = config.mail_from,
      reply_to      = config.mail_reply_to,
      to            = member.notify_email,
      subject       = config.mail_subject_prefix .. _("##{id} #{event}", { id = self.issue_id, event = self.event }),      content_type  = "text/plain; charset=UTF-8",
      content       = body
    }
  end

  print(body)
  print("")
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

  else
    return last_event_id

  end

end
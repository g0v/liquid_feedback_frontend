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
  
  slot.put("<pre>", encode.html_newlines(body), "</pre>")
  slot.put("<hr />")
end

function Event:send_next_notification(last_event_id)

  local event = Event:new_selector()
    :add_where{ "event.id > ?", last_id }
    :add_order_by("event.id")
    :limit(1)
    :optional_object_mode()
    :exec()

  last_id = nil
  if event then
    last_id = event.id
    local members_to_notify = Member:new_selector()
      :join("event_seen_by_member", nil, { "event_seen_by_member.seen_by_member_id = member.id AND event_seen_by_member.notify_level <= member.notify_level AND event_seen_by_member.id = ?", event.id } )
      :add_where("member.activated NOTNULL AND member.notify_email NOTNULL")
      :exec()
      
    ui.container{ content = _("Event #{id} -> #{num} members", { id = event.id, num = #members_to_notify }) }
    
    event:send_notification()
    
    return event.id

  else
    return last_event_id

  end

end
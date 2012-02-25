function send_notification(event)

  local url

  local body = ""
  
  body = body .. _("      Unit: #{name}\n", { name = event.issue.area.unit.name })
  body = body .. _("      Area: #{name}\n", { name = event.issue.area.name })
  body = body .. _("     Issue: ##{id}\n", { id = event.issue_id })
  body = body .. _("    Policy: #{phase}\n", { phase = event.issue.policy.name })
  body = body .. _("     Phase: #{phase}\n\n", { phase = event.state })
  body = body .. _("     Event: #{event}\n\n", { event = event.event })

  if event.initiative_id then
    url = request.get_absolute_baseurl() .. "initiative/show/" .. event.initiative_id .. ".html"
  elseif event.suggestion_id then
    url = request.get_absolute_baseurl() .. "suggestion/show/" .. event.suggestion_id .. ".html"
  else
    url = request.get_absolute_baseurl() .. "issue/show/" .. event.issue_id .. ".html"
  end
  
  body = body .. _("       URL: #{url}\n\n", { url = url })
  
  if event.initiative_id then
    local initiative = Initiative:by_id(event.initiative_id)
    body = body .. _("i#{id}: #{name}\n\n", { id = initiative.id, name = initiative.name })
  else
    local initiative_count = Initiative:new_selector()
      :add_where{ "initiative.issue_id = ?", event.issue_id }
      :count()
    local initiatives = Initiative:new_selector()
      :add_where{ "initiative.issue_id = ?", event.issue_id }
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
  
  if event.suggestion_id then
    local suggestion = Suggestion:by_id(event.suggestion_id)
    body = body .. _("#{name}\n\n", { name = suggestion.name })
  end
  
  slot.put("<pre>", encode.html_newlines(body), "</pre>")
  slot.put("<hr />")
end


    
slot.put_into("title", _"Notification settings")

slot.select("actions", function()
  ui.link{
    content = function()
        ui.image{ static = "icons/16/cancel.png" }
        slot.put(_"Cancel")
    end,
    module = "member",
    view = "settings"
  }
end)


util.help("member.settings.notification", _"Notification settings")

ui.form{
  attr = { class = "vertical" },
  module = "member",
  action = "update_notification",
  routing = {
    ok = {
      mode = "redirect",
      module = "index",
      view = "index"
    }
  },
  content = function()
    ui.tag{ tag = "p", _"Send me notifications about issues in following phases:" }
  
    ui.container{ content = function()
      ui.tag{
        tag = "input", 
        attr = { type = "radio", name = "notification_level", value = "voting" }
      }
      ui.tag{ content = _"Voting phase" }
      ui.tag{ tag = "ul", content = function()
        ui.tag{ tag = "li", content = _"Voting of an issue in one of my areas or I'm interested in starts" }
      end }
    end }

    ui.container{ content = function()
      ui.tag{
        tag = "input", 
        attr = { type = "radio", name = "notification_level", value = "frozen" }
      }
      ui.tag{ content = _"Frozen and voting phase" }
      ui.tag{ tag = "ul", content = function()
        ui.tag{ tag = "li", content = _"An issue in one of my areas or I'm interested in enters phase 'frozen'" }
        ui.tag{ tag = "li", content = _"A new initiative is created in an issue I'm interested in" }
        ui.tag{ tag = "li", content = _"Voting of an issue in one of my areas or I'm interested in starts" }
      end }
    end }

    ui.container{ content = function()
      ui.tag{
        tag = "input", 
        attr = { type = "radio", name = "notification_level", value = "discussion" }
      }
      ui.tag{ content = _"Discussion, frozen and voting phase" }
      ui.tag{ tag = "ul", content = function()
        ui.tag{ tag = "li", content = _"An issue in one of my areas or I'm interested in enters phase 'discussion'" }
        ui.tag{ tag = "li", content = _"A new initiative is created in an issue I'm interested in" }
        ui.tag{ tag = "li", content = _"The draft of an initiative I'm supporting is updated" }
        ui.tag{ tag = "li", content = _"An initiative I was supporting is revoked" }
        ui.tag{ tag = "li", content = _"A new suggestion is created in an initiative I'm supporting" }
        ui.tag{ tag = "li", content = _"An issue in one of my areas or I'm interested in enters phase 'frozen'" }
        ui.tag{ tag = "li", content = _"Voting of an issue in one of my areas or I'm interested in starts" }
      end }
    end }

    ui.container{ content = function()
      ui.tag{
        tag = "input", 
        attr = { type = "radio", name = "notification_level", value = "any" }
      }
      ui.tag{ content = _"Any phase" }
      ui.tag{ tag = "ul", content = function()
        ui.tag{ tag = "li", content = _"A new issue is created in one of my areas" }
        ui.tag{ tag = "li", content = _"An issue in one of my areas or i'm interested in enters phase 'discussion'" }
        ui.tag{ tag = "li", content = _"A new initiative is created in an issue I'm interested in" }
        ui.tag{ tag = "li", content = _"The draft of an initiative I'm supporting is updated" }
        ui.tag{ tag = "li", content = _"An initiative I was supporting is revoked" }
        ui.tag{ tag = "li", content = _"A new suggestion is created in an initiative I'm supporting" }
        ui.tag{ tag = "li", content = _"An issue in one of my areas or I'm interested in enters phase 'frozen'" }
        ui.tag{ tag = "li", content = _"Voting of an issue in one of my areas or I'm interested in starts" }
      end }
    end }

    ui.container{ content = function()
      ui.tag{
        tag = "input", 
        attr = { type = "radio", name = "notification_level", value = "none" }
      }
      ui.tag{ content = _"No notifications at all" }
    end }


    
    ui.submit{ value = _"Change display settings" }
  end
}

local last_id = 6000;

while last_id < 6050 do

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
    
    send_notification(event)

  end
end

  
-- select event.id, event.occurrence, membership.member_id NOTNULL as membership, interest.member_id NOTNULL as interest, supporter.member_id NOTNULL as supporter, event.event, event.state, issue.id, initiative.name FROM event JOIN issue ON issue.id = event.issue_id LEFT JOIN membership ON membership.area_id = issue.area_id AND membership.member_id = 41 LEFT JOIN interest ON interest.issue_id = issue.id AND interest.member_id = 41 LEFT JOIN initiative ON initiative.id = event.initiative_id LEFT JOIN supporter ON supporter.initiative_id = initiative.id AND supporter.member_id = 41 WHERE (((event.event = 'issue_state_changed' OR event.event = 'initiative_created_in_new_issue') AND membership.member_id NOTNULL OR interest.member_id NOTNULL) OR (event.event = 'initiative_created_in_existing_issue' AND interest.member_id NOTNULL) OR ((event.event = 'initiative_revoked' OR event.event = 'new_draft_created' OR event.event = 'suggestion_created') AND supporter.member_id NOTNULL)) AND event.id > 7000 ORDER by event.id ASC LIMIT 1;
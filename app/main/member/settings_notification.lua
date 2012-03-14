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
  action = "update_notify_level",
  routing = {
    ok = {
      mode = "redirect",
      module = "index",
      view = "index"
    }
  },
  content = function()
    ui.tag{ tag = "p", content = _"I like to receive notifications about events in my areas and issues:" }
  
    ui.container{ content = function()
      ui.tag{
        tag = "input", 
        attr = {
          id = "notify_level_none",
          type = "radio", name = "notify_level", value = "none",
          checked = app.session.member.notify_level == 'none' and "checked" or nil
        }
      }
      ui.tag{
        tag = "label", attr = { ['for'] = "notify_level_none" },
        content = _"No notifications at all"
      }
    end }
     
    slot.put("<br />")
  
    ui.container{ content = function()
      ui.tag{
        tag = "input", 
        attr = {
          id = "notify_level_all",
          type = "radio", name = "notify_level", value = "all",
          checked = app.session.member.notify_level == 'all' and "checked" or nil
        }
      }
      ui.tag{
        tag = "label", attr = { ['for'] = "notify_level_all" },
        content = _"All of them"
      }
    end }
    
    slot.put("<br />")

    ui.container{ content = function()
      ui.tag{
        tag = "input", 
        attr = {
          id = "notify_level_discussion",
          type = "radio", name = "notify_level", value = "discussion",
          checked = app.session.member.notify_level == 'discussion' and "checked" or nil
        }
      }
      ui.tag{
        tag = "label", attr = { ['for'] = "notify_level_discussion" },
        content = _"Only for issues reaching the discussion phase"
      }
    end }

    slot.put("<br />")

    ui.container{ content = function()
      ui.tag{
        tag = "input", 
        attr = {
          id = "notify_level_verification",
          type = "radio", name = "notify_level", value = "verification",
          checked = app.session.member.notify_level == 'verification' and "checked" or nil
        }
      }
      ui.tag{
        tag = "label", attr = { ['for'] = "notify_level_verification" },
        content = _"Only for issues reaching the frozen phase"
      }
    end }
    
    slot.put("<br />")

    ui.container{ content = function()
      ui.tag{
        tag = "input", 
        attr = {
          id = "notify_level_voting",
          type = "radio", name = "notify_level", value = "voting",
          checked = app.session.member.notify_level == 'voting' and "checked" or nil
        }
      }
      ui.tag{
        tag = "label", attr = { ['for'] = "notify_level_voting" },
        content = _"Only for issues reaching the voting phase"
      }
    end }

    slot.put("<br />")

    ui.submit{ value = _"Change notification settings" }
  end
}
 
-- select event.id, event.occurrence, membership.member_id NOTNULL as membership, interest.member_id NOTNULL as interest, supporter.member_id NOTNULL as supporter, event.event, event.state, issue.id, initiative.name FROM event JOIN issue ON issue.id = event.issue_id LEFT JOIN membership ON membership.area_id = issue.area_id AND membership.member_id = 41 LEFT JOIN interest ON interest.issue_id = issue.id AND interest.member_id = 41 LEFT JOIN initiative ON initiative.id = event.initiative_id LEFT JOIN supporter ON supporter.initiative_id = initiative.id AND supporter.member_id = 41 WHERE (((event.event = 'issue_state_changed' OR event.event = 'initiative_created_in_new_issue') AND membership.member_id NOTNULL OR interest.member_id NOTNULL) OR (event.event = 'initiative_created_in_existing_issue' AND interest.member_id NOTNULL) OR ((event.event = 'initiative_revoked' OR event.event = 'new_draft_created' OR event.event = 'suggestion_created') AND supporter.member_id NOTNULL)) AND event.id > 7000 ORDER by event.id ASC LIMIT 1;
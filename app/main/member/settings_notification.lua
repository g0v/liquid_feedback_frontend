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
 
-- select event.id, event.occurrence, membership.member_id NOTNULL as membership, interest.member_id NOTNULL as interest, supporter.member_id NOTNULL as supporter, event.event, event.state, issue.id, initiative.name FROM event JOIN issue ON issue.id = event.issue_id LEFT JOIN membership ON membership.area_id = issue.area_id AND membership.member_id = 41 LEFT JOIN interest ON interest.issue_id = issue.id AND interest.member_id = 41 LEFT JOIN initiative ON initiative.id = event.initiative_id LEFT JOIN supporter ON supporter.initiative_id = initiative.id AND supporter.member_id = 41 WHERE (((event.event = 'issue_state_changed' OR event.event = 'initiative_created_in_new_issue') AND membership.member_id NOTNULL OR interest.member_id NOTNULL) OR (event.event = 'initiative_created_in_existing_issue' AND interest.member_id NOTNULL) OR ((event.event = 'initiative_revoked' OR event.event = 'new_draft_created' OR event.event = 'suggestion_created') AND supporter.member_id NOTNULL)) AND event.id > 7000 ORDER by event.id ASC LIMIT 1;
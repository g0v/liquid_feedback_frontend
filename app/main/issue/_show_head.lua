local issue = param.get("issue", "table")
local initiative = param.get("initiative", "table")

local direct_voter

if app.session.member_id then
  direct_voter = DirectVoter:by_pk(issue.id, app.session.member.id)
end

if config.feature_rss_enabled then
  util.html_rss_head{ title = _"Initiatives in this issue (last created first)", module = "initiative", view = "list_rss", params = { issue_id = issue.id } }
  util.html_rss_head{ title = _"Initiatives in this issue (last updated first)", module = "initiative", view = "list_rss", params = { issue_id = issue.id, order = "last_updated" } }
end

slot.select("title", function()
  ui.link{
    content = _("Issue ##{id}", { id = issue.id }),
    module = "issue",
    view = "show",
    id = issue.id
  }
  slot.put(" &middot; ")
  ui.link{
    content = issue.area.name,
    module = "area",
    view = "show",
    id = issue.area.id
  }
  if not config.single_unit_id then
    slot.put(" &middot; ")
    ui.link{
      content = issue.area.unit.name,
      module = "area",
      view = "list",
      params = { unit_id = issue.area.unit_id }
    }
  end
end)


slot.select("title2", function()
  ui.tag{
    tag = "div",
    content = function()
    
      ui.link{
        text = issue.policy.name,
        module = "policy",
        view = "show",
        id = issue.policy.id
      }

      slot.put(" &middot; ")
      ui.tag{ content = issue.state_name }

      if issue.state_time_left then
        slot.put(" &middot; ")
        ui.tag{ content = _("#{time_left} left", { time_left = issue.state_time_left }) }
      end

    end
  }

  
end)

slot.select("actions", function()

  if app.session.member_id then

    if issue.state == 'voting' then
      local text
      if not direct_voter then
        text = _"Vote now"
      else
        text = _"Change vote"
      end
      ui.link{
        content = function()
          ui.image{ static = "icons/16/email_open.png" }
          slot.put(text)
        end,
        module = "vote",
        view = "list",
        params = { issue_id = issue.id }
      }
    end

    execute.view{
      module = "interest",
      view = "_show_box",
      params = { issue = issue }
    }

    if not issue.closed then
      execute.view{
        module = "delegation",
        view = "_show_box",
        params = { issue_id = issue.id,
                   initiative_id = initiative and initiative.id or nil}
      }
    end

  end

  if config.issue_discussion_url_func then
    local url = config.issue_discussion_url_func(issue)
    ui.link{
      attr = { target = "_blank" },
      external = url,
      content = function()
        ui.image{ static = "icons/16/comments.png" }
        slot.put(_"Discussion on issue")
      end,
    }
  end
end)

if app.session.member_id then
  slot.select("actions", function()
    if not issue.fully_frozen and not issue.closed then
      ui.link{
        image  = { static = "icons/16/script_add.png" },
        attr   = { class = "action" },
        text   = _"Create alternative initiative",
        module = "initiative",
        view   = "new",
        params = { issue_id = issue.id }
      }
    end
  end)
end

local issue = param.get("issue", "table")

if config.public_access_issue_head and not app.session.member_id then
  config.public_access_issue_head(issue)
end

if app.session.member_id and issue.state == 'voting' and not direct_voter then
  ui.container{
    attr = { class = "voting_active_info" },
    content = function()
      slot.put(_"Voting for this issue is currently running!")
      slot.put(" ")
      if app.session.member_id then
        ui.link{
          content = function()
            slot.put(_"Vote now")
          end,
          module = "vote",
          view = "list",
          params = { issue_id = issue.id }
        }
      end
    end
  }
  slot.put("<br />")
end


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

slot.select("path", function()
end)

slot.select("title", function()
  ui.link{
    content = issue.area.name,
    module = "area",
    view = "show",
    id = issue.area.id
  }
  slot.put(" &middot; ")
  ui.link{
    content = _("Issue ##{id}", { id = issue.id }),
    module = "issue",
    view = "show",
    id = issue.id
  }
  slot.put(" &middot; ")
  ui.tag{
    tag = "span",
    content = issue.state_name,
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

    execute.view{
      module = "issue",
      view = "_show_vote_later_box",
      params = { issue = issue }
    }

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


execute.view{
  module = "issue",
  view = "_show_box",
  params = { issue = issue }
}

--  ui.twitter("http://example.com/t" .. tostring(issue.id))

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


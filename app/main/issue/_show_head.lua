local issue = param.get("issue", "table")

slot.put_into("html_head", '<link rel="alternate" type="application/rss+xml" title="RSS" href="../show/' .. tostring(issue.id) .. '.rss" />')

slot.select("path", function()
  ui.link{
    content = _"Area '#{name}'":gsub("#{name}", issue.area.name),
    module = "area",
    view = "show",
    id = issue.area.id
  }
end)

slot.select("title", function()
  ui.link{
    content = _"Issue ##{id} (#{policy_name})":gsub("#{id}", issue.id):gsub("#{policy_name}", issue.policy.name),
    module = "issue",
    view = "show",
    id = issue.id
  }
end)


slot.select("actions", function()

  if issue.state == 'voting' then
    ui.link{
      content = function()
        ui.image{ static = "icons/16/email_open.png" }
        slot.put(_"Vote now")
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
  -- TODO performance
  local interest = Interest:by_pk(issue.id, app.session.member.id)
  if not issue.closed and not issue.fully_frozen then
    if not interest then
      ui.link{
        content = function()
          ui.image{ static = "icons/16/user_add.png" }
          slot.put(_"Add my interest")
        end,
        module = "interest",
        action = "update",
        params = { issue_id = issue.id },
        routing = { default = { mode = "redirect", module = "issue", view = "show", id = issue.id } }
      }
    end
  end

  if not issue.closed then
    execute.view{
      module = "delegation",
      view = "_show_box",
      params = { issue_id = issue.id }
    }
  end

--[[ 
  if issue.state == "accepted" then
    -- TODO
    ui.link{
      content = function()
        ui.image{ static = "icons/16/time.png" }
        slot.put(_"Vote now/later")
      end,
    }
  end
--]]

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


if issue.state == 'voting' then
  ui.container{
    attr = { class = "voting_active_info" },
    content = function()
      slot.put(_"Voting for this issue is currently running!")
      slot.put(" ")
      ui.link{
        content = function()
          slot.put(_"Vote now")
        end,
        module = "vote",
        view = "list",
        params = { issue_id = issue.id }
      }
    end
  }
  slot.put("<br />")
end


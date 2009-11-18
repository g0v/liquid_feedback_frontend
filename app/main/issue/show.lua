local issue = Issue:by_id(param.get_id())

slot.put_into("html_head", '<link rel="alternate" type="application/rss+xml" title="RSS" href="../show/' .. tostring(issue.id) .. '.rss" />')

slot.select("path", function()
  ui.link{
    content = _"Area '#{name}'":gsub("#{name}", issue.area.name),
    module = "area",
    view = "show",
    id = issue.area.id
  }
end)

slot.put_into("title", encode.html(_"Issue ##{id} (#{policy_name})":gsub("#{id}", issue.id):gsub("#{policy_name}", issue.policy.name)))

slot.select("actions", function()
  if not issue.closed then
    ui.link{
      content = function()
        ui.image{ static = "icons/16/table_go.png" }
        slot.put(_"Delegate")
      end,
      module = "delegation",
      view = "new",
      params = { issue_id = issue.id }
    }
  end

  ui.twitter("http://example.com/t" .. tostring(issue.id))

end)

execute.view{
  module = "interest",
  view = "_show_box",
  params = { issue = issue }
}

execute.view{
  module = "delegation",
  view = "_show_box",
  params = { issue_id = issue.id }
}

ui.tabs{
  {
    name = "initiatives",
    label = _"Initiatives",
    content = function()
      execute.view{
        module = "initiative",
        view = "_list",
        params = { 
          issue = issue,
          initiatives_selector = issue:get_reference_selector("initiatives")
        }
      }
      slot.put("<br />")
      if not issue.frozen and not issue.closed then
        ui.link{
          attr = { class = "action" },
          content = function()
            ui.image{ static = "icons/16/script_add.png" }
            slot.put(_"Add new initiative to issue")
          end,
          module = "initiative",
          view = "new",
          params = { issue_id = issue.id }
        }
      end
    end
  },
--[[  {
    name = "voting_requests",
    label = _"Voting requests",
    content = function()
      execute.view{
        module = "issue_voting_request",
        view = "_list",
        params = { issue = issue }
      }
    end
  },
--]]
  {
    name = "details",
    label = _"Details",
    content = function()
      ui.form{
        record = issue,
        readonly = true,
        attr = { class = "vertical" },
        content = function()
          trace.debug(issue.created)
          ui.field.text{ label = _"State", name = "state" }
          ui.field.timestamp{ label = _"Created at", name = "created" }
          ui.field.timestamp{ label = _"Accepted", name = "accepted" }
          ui.field.timestamp{ label = _"Half frozen", name = "half_frozen" }
          ui.field.timestamp{ label = _"Fully frozen", name = "fully_frozen" }
          ui.field.timestamp{ label = _"Closed", name = "closed" }
          ui.field.potential_issue_weight{ label = _"Potential weight", name = "potential_weight" }
          ui.field.vote_now{ label = _"Vote now", name = "vote_now" }
          ui.field.vote_later{ label = _"Vote later", name = "vote_later" }
        end
      }
    end
  },
}



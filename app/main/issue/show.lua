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

execute.view{
  module = "issue",
  view = "_show_box",
  params = { issue = issue }
}

ui.tabs{
  {
    name = "initiatives",
    label = _"Initiatives",
    content = function()      execute.view{
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
    name = "delegations",
    label = _"Delegations",
    content = function()
      execute.view{
        module = "delegation",
        view = "_list",
        params = { delegations_selector = issue:get_reference_selector("delegations") }
      }
    end
  },
  {
    name = "details",
    label = _"Details",
    content = function()
      local policy = issue.policy
      ui.form{
        record = issue,
        readonly = true,
        attr = { class = "vertical" },
        content = function()
          ui.field.text{ label = _"State", name = "state" }
          ui.field.timestamp{ label = _"Created at",            name = "created" }
          ui.field.text{      label = _"admission_time",        value = policy.admission_time }
          ui.field.integer{   label = _"issue_quorum_num",      value = policy.issue_quorum_num }
          ui.field.integer{   label = _"issue_quorum_den",      value = policy.issue_quorum_den }
          ui.field.timestamp{ label = _"Accepted",              name = "accepted" }
          ui.field.text{      label = _"discussion_time",       value = policy.discussion_time }
          ui.field.vote_now{   label = _"Vote now", name = "vote_now" }
          ui.field.vote_later{ label = _"Vote later", name = "vote_later" }
          ui.field.timestamp{ label = _"Half frozen",           name = "half_frozen" }
          ui.field.text{      label = _"verification_time",     value = policy.verification_time }
          ui.field.integer{ label   = _"initiative_quorum_num", value = policy.initiative_quorum_num }
          ui.field.integer{ label   = _"initiative_quorum_den", value = policy.initiative_quorum_den }
          ui.field.timestamp{ label = _"Fully frozen",          name = "fully_frozen" }
          ui.field.text{      label = _"voting_time",           value = policy.voting_time }
          ui.field.timestamp{ label = _"Closed",                name = "closed" }
        end
      }
      ui.form{
        record = issue.policy,
        readonly = true,
        content = function()
        end
      }
    end
  },
}



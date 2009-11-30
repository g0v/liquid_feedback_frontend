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
      if not issue.fully_frozen and not issue.closed then
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
    name = "interested_members",
    label = _"Interested members",
    content = function()
      execute.view{
        module = "member",
        view = "_list",
        params = {
          issue = issue,
          members_selector =  issue:get_reference_selector("interested_members_snapshot")
            :join("issue", nil, "issue.id = direct_interest_snapshot.issue_id")
            :add_field("direct_interest_snapshot.weight")
            :add_where("direct_interest_snapshot.event = issue.latest_snapshot_event")
        }
      }
    end
  },
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
          ui.field.text{      label = _"Admission time",        value = policy.admission_time }
          ui.field.text{
            label = _"Issue quorum",
            value = format.percentage(policy.issue_quorum_num / policy.issue_quorum_den)
          }
          ui.field.timestamp{ label = _"Accepted at",              name = "accepted" }
          ui.field.text{      label = _"Discussion time",       value = policy.discussion_time }
          ui.field.vote_now{   label = _"Vote now", name = "vote_now" }
          ui.field.vote_later{ label = _"Vote later", name = "vote_later" }
          ui.field.timestamp{ label = _"Half frozen at",           name = "half_frozen" }
          ui.field.text{      label = _"Verification time",     value = policy.verification_time }
          ui.field.text{
            label   = _"Initiative quorum",
            value = format.percentage(policy.initiative_quorum_num / policy.initiative_quorum_den)
          }
          ui.field.timestamp{ label = _"Fully frozen at",          name = "fully_frozen" }
          ui.field.text{      label = _"Voting time",           value = policy.voting_time }
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



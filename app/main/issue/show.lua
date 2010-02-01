local issue = Issue:by_id(param.get_id())

execute.view{
  module = "issue",
  view = "_show_head",
  params = { issue = issue }
}

util.help("issue.show")

local voting_requested_percentage = 0
if issue.vote_later and issue.population and issue.population > 0 then
  voting_requested_percentage = math.ceil(issue.vote_later  / issue.population * 100)
end
local voting_requested_string = "(" .. tostring(voting_requested_percentage) .. "%)"

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
    name = "voting_requests",
    label = _"Vote later requests" .. " " .. voting_requested_string,
    content = function()
      execute.view{
        module = "member",
        view = "_list",
        params = {
          issue = issue,
          members_selector =  issue:get_reference_selector("interested_members_snapshot")
            :join("issue", nil, "issue.id = direct_interest_snapshot.issue_id")
            :add_where("direct_interest_snapshot.voting_requested = false")
        }
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



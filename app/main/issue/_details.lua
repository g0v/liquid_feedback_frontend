local issue = param.get("issue", "table")

function bool2str(value)
  if value then
    return _("Yes")
  else
    return _("No")
  end
end

function dtdd(label, value, class)
  ui.tag{ tag = "dt", attr = { class = class or "" }, content = label }
  ui.tag{ tag = "dd", attr = { class = class or "" }, content = value }
end

local policy = issue.policy

ui.container{
  attr = { class = "initiative_head", style = "width:49%;float:left" },
  content = function()
    ui.container{ attr = { class = "title" }, content = _"Issue Details" }
    ui.container{ attr = { class = "content" }, content = function()

      ui.tag{
        tag = "dl",
        attr = { style = "width:59%;float:left" },
        content = function()
          -- new
          dtdd( _"Created", format.timestamp(issue.created) )
          dtdd( _"Admission time", issue.admission_time, "duration" )
          dtdd( _"Issue quorum", format.percentage(policy.issue_quorum_num / policy.issue_quorum_den), "quorum" )
          if issue.population then
            dtdd( _"Currently required", math.ceil(issue.population * policy.issue_quorum_num / policy.issue_quorum_den), "quorum" )
          end
          -- discussion
          if issue.accepted then
            dtdd( _"Accepted", format.timestamp(issue.accepted) )
          end
          dtdd( _"Discussion time", issue.discussion_time, "duration" )
          -- frozen
          if issue.half_frozen then
            dtdd( _"Half frozen", format.timestamp(issue.half_frozen) )
          end
          dtdd( _"Verification time", issue.verification_time, "duration" )
          dtdd( _"Initiative quorum", format.percentage(policy.initiative_quorum_num / policy.initiative_quorum_den), "quorum" )
          if issue.population then
            dtdd( _"Currently required", math.ceil(issue.population * (issue.policy.initiative_quorum_num / issue.policy.initiative_quorum_den)), "quorum" )
          end
          -- voting
          if issue.fully_frozen then
            dtdd( _"Fully frozen", format.timestamp(issue.fully_frozen) )
          end
          dtdd( _"Voting time", issue.voting_time, "duration" )
          -- closed
          if issue.closed then
            dtdd( _"Closed", format.timestamp(issue.closed) )
          end
        end
      }

      ui.tag{
        tag = "dl",
        attr = { style = "margin-left:61%" },
        content = function()
          dtdd( _"Population", issue.population )
          dtdd( _"State", issue.state_name )
          if issue.snapshot then
            dtdd( _"Last snapshot", format.timestamp(issue.snapshot) )
          end
        end
      }

    end }
  end
}

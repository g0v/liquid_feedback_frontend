local policy = Policy:by_id(param.get_id())

slot.put_into("title", encode.html(_("Policy '#{name}'", { name = policy.name })))

ui.form{
  attr = { class = "vertical" },
  record = policy,
  content = function()
    ui.field.text{ label = _"Name", value = policy.name }

    ui.field.text{ label = _"New", value = "≤ " .. policy.admission_time }
    ui.field.text{ label = _"Discussion", value = policy.discussion_time }
    ui.field.text{ label = _"Frozen", value = policy.verification_time }
    ui.field.text{ label = _"Voting", value = policy.voting_time }

    ui.field.text{
      label = _"Issue quorum",
      value = "≥ " .. tostring(policy.issue_quorum_num) .. "/" .. tostring(policy.issue_quorum_den)
    }
    ui.field.text{
      label = _"Initiative quorum",
      value = "≥ " .. tostring(policy.initiative_quorum_num) .. "/" .. tostring(policy.initiative_quorum_den)
    }
    ui.field.text{
      label = _"Majority",
      value = (policy.majority_strict and ">" or "≥" ) .. " " .. tostring(policy.majority_num) .. "/" .. tostring(policy.majority_den)
    }

    ui.container{
      attr = { class = "suggestion_content wiki" },
      content = function()
        ui.tag{
          tag = "p",
          content = policy.description
        }
      end
    }

  end
}

local initiative = param.get("initiative", "table")

ui.form{
  attr = { class = "vertical" },
  record = initiative,
  readonly = true,
  content = function()
    local policy = initiative.issue.policy
    ui.field.text{ label = _"Issue policy", value = initiative.issue.policy.name }
    ui.field.text{
      label = _"Created at",
      value = tostring(initiative.created)
    }
    if initiative.revoked then
      ui.field.text{
         label = _"Revoked at",
         value = format.timestamp(initiative.revoked)
       }
    end
    ui.field.text{
      label   = _"Initiative quorum",
      value = format.percentage(policy.initiative_quorum_num / policy.initiative_quorum_den)
    }
    ui.field.text{
      label   = _"Currently required",
      value = math.ceil(initiative.issue.population * (policy.initiative_quorum_num / policy.initiative_quorum_den)),
    }
  -- ui.field.date{ label = _"Revoked at", name = "revoked" }
    ui.field.boolean{ label = _"Admitted", name = "admitted" }
  end
}

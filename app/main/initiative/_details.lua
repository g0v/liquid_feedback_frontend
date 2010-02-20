local initiative = param.get("initiative", "table")

ui.form{
  attr = { class = "vertical" },
  record = initiative,
  readonly = true,
  content = function()
    ui.field.text{ label = _"Issue policy", value = initiative.issue.policy.name }
    ui.field.text{
      label = _"Created at",
      value = tostring(initiative.created)
    }
    ui.field.text{
      label = _"Created at",
      value = format.timestamp(initiative.created)
    }
  -- ui.field.date{ label = _"Revoked at", name = "revoked" }
    ui.field.boolean{ label = _"Admitted", name = "admitted" }
  end
}

local initiative = param.get("initiative", "table")

ui.container{ content = _"Initiative details" }

ui.form{
  attr = { class = "vertical" },
  record = initiative,
  readonly = true,
  content = function()
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
    ui.field.boolean{ label = _"Admitted", name = "admitted" }
  end
}

ui.container{ content = _"Issue details" }

execute.view{ module = "issue", view = "_details", params = { issue = initiative.issue } }
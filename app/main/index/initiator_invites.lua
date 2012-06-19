

local initiatives_selector = Initiator:selector_for_invites(app.session.member_id)

if initiatives_selector:count() > 0 then
  ui.container{
    attr = { style = "font-weight: bold;" },
    content = _"Initiatives that invited you to become initiator:"
  }

  execute.view{
    module = "initiative",
    view = "_list",
    params = { initiatives_selector = initiatives_selector }
  }
else
  ui.field.text{ value = _"You are currently not invited to any initiative." }
end
local member = param.get("member", "table")

ui.form{
  attr = { class = "vertical" },
  record = member,
  readonly = true,
  content = function()
    ui.field.boolean{ label = _"Admin?",       name = "admin" }
    ui.field.boolean{ label = _"Locked?",      name = "locked" }
    if member.ident_number then
      ui.field.text{    label = _"Ident number", name = "ident_number" }
    end
    ui.submit{        text  = _"Save" }
  end
}

ui.tabs{
  {
    name = "areas",
    label = _"Areas",
    content = function()
      execute.view{
        module = "area",
        view = "_list",
        params = { areas_selector = member:get_reference_selector("areas") }
      }
    end
  },
  {
    name = "issues",
    label = _"Issues",
    content = function()
      execute.view{
        module = "issue",
        view = "_list",
        params = { issues_selector = member:get_reference_selector("issues") }
      }
    end
  },
  {
    name = "initiatives",
    label = _"Initiatives",
    content = function()
      execute.view{
        module = "initiative",
        view = "_list",
        params = { initiatives_selector = member:get_reference_selector("supported_initiatives") }
      }
    end
  },
  {
    name = "incoming_delegations",
    label = _"Incoming delegations",
    content = function()
      execute.view{
        module = "delegation",
        view = "_list",
        params = { delegations_selector = member:get_reference_selector("incoming_delegations"), incoming = true }
      }
    end
  },
  {
    name = "outgoing_delegations",
    label = _"Outgoing delegations",
    content = function()
      execute.view{
        module = "delegation",
        view = "_list",
        params = { delegations_selector = member:get_reference_selector("outgoing_delegations"), outgoing = true }
      }
    end
  },
  {
    name = "contacts",
    label = _"Published contacts",
    content = function()
      execute.view{
        module = "member",
        view = "_list",
        params = { members_selector = member:get_reference_selector("saved_members"):add_where("public") }
      }
    end
  },
}

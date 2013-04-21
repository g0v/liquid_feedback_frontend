local show_not_in_use = param.get("show_not_in_use", atom.boolean) or false

ui.title(_"Policy list")


ui.actions(function()

  ui.link{
    text = _"Admin menu",
    module = "admin",
    view = "index"
  }
  slot.put(" &middot; ")

  if show_not_in_use then
    ui.link{
      text = _"Show policies in use",
      module = "admin",
      view = "policy_list"
    }
  else
    ui.link{
      text = _"Create new policy",
      module = "admin",
      view = "policy_show"
    }
    slot.put(" &middot; ")
    ui.link{
      text = _"Show policies not in use",
      module = "admin",
      view = "policy_list",
      params = { show_not_in_use = true }
    }
  end

end)


execute.view{
  module = "policy",
  view = "_list",
  params = {
    admin = true,
    show_not_in_use = show_not_in_use,
    policies = Policy:build_selector{ active = not show_not_in_use }:exec()
  }
}

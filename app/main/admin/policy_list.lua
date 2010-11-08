local show_not_in_use = param.get("show_not_in_use", atom.boolean) or false

local policies = Policy:build_selector{ active = not show_not_in_use }:exec()


slot.put_into("title", _"Policy list")


slot.select("actions", function()

  if show_not_in_use then
    ui.link{
      attr = { class = { "admin_only" } },
      text = _"Show policies in use",
      module = "admin",
      view = "policy_list"
    }

  else
    ui.link{
      attr = { class = { "admin_only" } },
      text = _"Create new policy",
      module = "admin",
      view = "policy_show"
    }
    ui.link{
      attr = { class = { "admin_only" } },
      text = _"Show policies not in use",
      module = "admin",
      view = "policy_list",
      params = { show_not_in_use = true }
    }

  end

end)


ui.list{
  records = policies,
  columns = {

    { label = _"Policy", name = "name" },

    { content = function(record)
        ui.link{
          attr = { class = { "action admin_only" } },
          text = _"Edit",
          module = "admin",
          view = "policy_show",
          id = record.id
        }
      end
    }

  }
}
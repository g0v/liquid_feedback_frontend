local area = Area:new_selector():add_where{ "id = ?", param.get_id() }:single_object_mode():exec()

slot.put_into("title", encode.html(_"Area '#{name}'":gsub("#{name}", area.name)))

ui.container{
  attr = { class = "vertical"},
  content = function()
    ui.field.text{ value = area.description }
  end
}


slot.select("actions", function()
  ui.link{
    content = function()
      ui.image{ static = "icons/16/table_go.png" }
      slot.put(_"Delegate")
    end,
    module = "delegation",
    view = "new",
    params = { area_id = area.id }
  }
  ui.link{
    content = function()
      ui.image{ static = "icons/16/folder_add.png" }
      slot.put(_"Create new issue")
    end,
    module = "initiative",
    view = "new",
    params = { area_id = area.id }
  }
end)

execute.view{
  module = "membership",
  view = "_show_box",
  params = { area = area }
}

execute.view{
  module = "delegation",
  view = "_show_box",
  params = { area_id = area.id }
}

ui.tabs{
  {
    name = "issues",
    label = _"Issues",
    content = function()
      execute.view{
        module = "issue",
        view = "_list",
        params = { issues_selector = area:get_reference_selector("issues"), for_area_list = true }
      }
    end
  },
  {
    name = "members",
    label = _"Members",
    content = function()
      execute.view{
        module = "member",
        view = "_list",
        params = { members_selector = area:get_reference_selector("members") }
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
        params = { delegations_selector = area:get_reference_selector("delegations") }
      }
    end
  },
}


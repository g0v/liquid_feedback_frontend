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
      ui.image{ static = "icons/16/folder_add.png" }
      slot.put(_"Create new issue")
    end,
    module = "initiative",
    view = "new",
    params = { area_id = area.id }
  }
  ui.link{
    content = function()
      ui.image{ static = "icons/16/table_go.png" }
      slot.put(_"Delegate")
    end,
    module = "delegation",
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
    name = "new",
    label = _"New",
    content = function()
      execute.view{
        module = "issue",
        view = "_list",
        params = { issues_selector = area:get_reference_selector("issues"):add_where("issue.accepted ISNULL AND issue.closed ISNULL"), for_area_list = true }
      }
    end
  },
  {
    name = "accepted",
    label = _"In discussion",
    content = function()
      execute.view{
        module = "issue",
        view = "_list",
        params = { issues_selector = area:get_reference_selector("issues"):add_where("issue.accepted NOTNULL AND issue.half_frozen ISNULL AND issue.closed ISNULL"), for_area_list = true }
      }
    end
  },
  {
    name = "half_frozen",
    label = _"Frozen",
    content = function()
      execute.view{
        module = "issue",
        view = "_list",
        params = { issues_selector = area:get_reference_selector("issues"):add_where("issue.half_frozen NOTNULL AND issue.closed ISNULL"), for_area_list = true }
      }
    end
  },
  {
    name = "frozen",
    label = _"Voting",
    content = function()
      execute.view{
        module = "issue",
        view = "_list",
        params = { issues_selector = area:get_reference_selector("issues"):add_where("issue.fully_frozen NOTNULL AND issue.closed ISNULL"), for_area_list = true }
      }
    end
  },
  {
    name = "finished",
    label = _"Finished",
    content = function()
      execute.view{
        module = "issue",
        view = "_list",
        params = { issues_selector = area:get_reference_selector("issues"):add_where("issue.closed NOTNULL AND ranks_available"), for_area_list = true }
      }
    end
  },
  {
    name = "cancelled",
    label = _"Cancelled",
    content = function()
      execute.view{
        module = "issue",
        view = "_list",
        params = { issues_selector = area:get_reference_selector("issues"):add_where("issue.closed NOTNULL AND NOT ranks_available"), for_area_list = true }
      }
    end
  },
}


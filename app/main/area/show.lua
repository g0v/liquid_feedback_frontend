local area = Area:by_id(param.get_id())


app.html_title.title = area.name
app.html_title.subtitle = _("Area")

util.help("area.show")


if config.feature_rss_enabled then
  util.html_rss_head{ title = _"Initiatives in this area (last created first)", module = "initiative", view = "list_rss", params = { area_id = area.id } }
  util.html_rss_head{ title = _"Initiatives in this area (last updated first)", module = "initiative", view = "list_rss", params = { area_id = area.id } }
end


slot.put_into("title", area.name_with_unit_name)


ui.container{
  attr = { class = "vertical"},
  content = function()
    ui.field.text{ value = area.description }
  end
}


if app.session.member_id then

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

end


execute.view{
  module = "area",
  view = "show_tab",
  params = { area = area }
}


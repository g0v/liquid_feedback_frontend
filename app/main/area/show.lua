local area = Area:by_id(param.get_id())


app.html_title.title = area.name
app.html_title.subtitle = _("Area")

util.help("area.show")


if config.feature_rss_enabled then
  util.html_rss_head{ title = _"Initiatives in this area (last created first)", module = "initiative", view = "list_rss", params = { area_id = area.id } }
  util.html_rss_head{ title = _"Initiatives in this area (last updated first)", module = "initiative", view = "list_rss", params = { area_id = area.id } }
end


slot.select("title", function()
  ui.tag{ content =  area.name }

  if not config.single_unit_id then
    slot.put(" &middot; ")
    ui.link{
      content = area.unit.name,
      module = "area",
      view = "list",
      params = { unit_id = area.unit_id }
    }
  end


end)

ui.container{
  attr = { class = "vertical"},
  content = function()
    ui.field.text{ value = area.description }
  end
}


if app.session.member_id then
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

  if app.session.member:has_voting_right_for_unit_id(area.unit_id) then
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
  end


end

if app.session.member then
  execute.view{
    module = "area",
    view = "show_tab",
    params = { area = area }
  }
else
  execute.view{
    module = "issue",
    view = "_list",
    params = {
      issues_selector = area:get_reference_selector("issues"),
      filter = cgi.params["filter"],
      filter_voting = param.get("filter_voting"),
      for_area_list = true
    }
  }
end

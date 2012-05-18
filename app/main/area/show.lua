local area = Area:by_id(param.get_id())


app.html_title.title = area.name
app.html_title.subtitle = _("Area")

util.help("area.show")


if config.feature_rss_enabled then
  util.html_rss_head{ title = _"Initiatives in this area (last created first)", module = "initiative", view = "list_rss", params = { area_id = area.id } }
  util.html_rss_head{ title = _"Initiatives in this area (last updated first)", module = "initiative", view = "list_rss", params = { area_id = area.id } }
end


execute.view{ module = "area", view = "_head", params = { area = area } }

ui.container{
  attr = { class = "vertical"},
  content = function()
    ui.field.text{ value = area.description }
  end
}




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

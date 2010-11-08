local areas_selector = Area:build_selector{ active = true }


if app.session.member_id then
  slot.put_into("title", _'Area list')
else
  slot.put_into("title", encode.html(config.app_title))
end


if not app.session.member_id and config.motd_public then
  local help_text = config.motd_public
  ui.container{
    attr = { class = "wiki motd" },
    content = function()
      slot.put(format.wiki_text(help_text))
    end
  }
end

util.help("area.list", _"Area list")


execute.view{
  module = "area",
  view = "_list",
  params = { areas_selector = areas_selector }
}

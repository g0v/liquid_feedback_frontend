-- TODO support multiple units
local unit_id = param.get("units", atom.integer)
local areas_selector = Area:build_selector{ active = true, unit_id = unit_id }

local unit = Unit:by_id(unit_id)


if app.session.member_id then
  slot.put_into("title", _("Area list of unit '#{unit_name}'", { unit_name = unit.name }))
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
  module = "delegation",
  view = "_show_box",
  params = { unit_id = unit_id }
}


execute.view{
  module = "area",
  view = "_list",
  params = { areas_selector = areas_selector }
}

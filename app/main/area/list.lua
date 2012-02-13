local unit_id = config.single_unit_id or param.get("unit_id", atom.integer)
local title = param.get("title", "function")

local areas_selector = Area:build_selector{ active = true, unit_id = unit_id }
areas_selector:add_order_by("member_weight DESC")

local unit = Unit:by_id(unit_id)


if not config.single_unit_id then
  slot.put_into("title", unit.name)
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

if app.session.member_id then
  execute.view{
    module = "delegation",
    view = "_show_box",
    params = { unit_id = unit_id }
  }
end


execute.view{
  module = "area",
  view = "_list",
  params = { areas_selector = areas_selector, title = title }
}

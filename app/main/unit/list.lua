local units = Unit:get_flattened_tree{ active = true }

slot.put_into("title", encode.html(config.app_title))

if not app.session.member_id and config.motd_public then
  local help_text = config.motd_public
  ui.container{
    attr = { class = "wiki motd" },
    content = function()
      slot.put(format.wiki_text(help_text))
    end
  }
end

util.help("unit.list", _"Unit list")

ui.list{
  records = units,
  columns = {
    {
      label = "name",
      content = function(unit)
        ui.link{ text = unit.name, module = "area", view = "list", params = { unit_id = unit.id } }
      end 
    }
  }
}
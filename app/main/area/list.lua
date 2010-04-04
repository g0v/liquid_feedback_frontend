if app.session.member_id then
  slot.put_into("title", _'Area list')
else
  slot.put_into("title", encode.html(config.app_title))
end

local lang = locale.get("lang")
local basepath = request.get_app_basepath() 
local file_name = basepath .. "/locale/motd/" .. lang .. "_public.txt"
local file = io.open(file_name)
if file ~= nil then
  local help_text = file:read("*a")
  if #help_text > 0 then
    ui.container{
      attr = { class = "motd wiki" },
      content = function()
        slot.put(format.wiki_text(help_text))
      end
    }
  end
end

util.help("area.list", _"Area list")

local areas_selector = Area:new_selector():add_where("active")

execute.view{
  module = "area",
  view = "_list",
  params = { areas_selector = areas_selector }
}

--[[
execute.view{
  module = "delegation",
  view = "_show_box"
}
--]]

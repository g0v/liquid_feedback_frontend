local lang = locale.get("lang")
local basepath = request.get_app_basepath() 
local file_name = basepath .. "/locale/motd/" .. lang .. ".txt"
local file = io.open(file_name)
if file ~= nil then
  local help_text = file:read("*a")
  if #help_text > 0 then
    ui.container{
      attr = { class = "wiki" },
      content = function()
        slot.put(format.wiki_text(help_text))
      end
    }
  end
end

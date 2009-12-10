slot.select("title", function()
  execute.view{
    module = "member_image",
    view = "_show",
    params = {
      member = app.session.member, 
      image_type = "avatar"
    }
  }
end)

slot.select("title", function()
  ui.container{
    attr = { class = "lang_chooser" },
    content = function()
      for i, lang in ipairs{"en", "de"} do
        ui.link{
          content = function()
            ui.image{
              static = "lang/" .. lang .. ".png",
              attr = { style = "margin-left: 0.5em;", alt = lang }
            }
          end,
          module = "index",
          action = "set_lang",
          params = { lang = lang },
          routing = {
            default = {
              mode = "redirect",
              module = request.get_module(),
              view = request.get_view(),
              id = param.get_id_cgi(),
              params = param.get_all_cgi()
            }
          }
        }
      end
    end
  }
end)

slot.put_into("title", encode.html(config.app_title))

slot.select("actions", function()

  ui.link{
    content = function()
        ui.image{ static = "icons/16/application_form.png" }
        slot.put(_"Edit my profile")
    end,
    module = "member",
    view = "edit"
  }

  ui.link{
    content = function()
        ui.image{ static = "icons/16/user_gray.png" }
        slot.put(_"Upload images")
    end,
    module = "member",
    view = "edit_images"
  }

  execute.view{
    module = "delegation",
    view = "_show_box"
  }

  ui.link{
    content = function()
        ui.image{ static = "icons/16/key.png" }
        slot.put(_"Change password")
    end,
    module = "index",
    view = "change_password"
  }

end)

local lang = locale.get("lang")
local basepath = request.get_app_basepath() 
local file_name = basepath .. "/locale/motd/" .. lang .. ".txt"
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


util.help("index.index", _"Home")

execute.view{
  module = "member",
  view = "_show",
  params = { member = app.session.member }
}


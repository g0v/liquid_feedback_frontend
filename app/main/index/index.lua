slot.select("title", function()
  ui.image{
    attr = { class = "avatar" },
    module = "member",
    view = "avatar",
    extension = "jpg",
    id = app.session.member.id
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
  slot.put(_"Logged in as:")
  slot.put(" <b>")
  slot.put(app.session.member.login)
  slot.put("</b> | ")

  ui.link{
    content = function()
        ui.image{ static = "icons/16/user_gray.png" }
        slot.put(_"Upload avatar")
    end,
    module = "member",
    view = "edit_avatar"
  }

  ui.link{
    content = function()
        ui.image{ static = "icons/16/application_form.png" }
        slot.put(_"Edit my page")
    end,
    module = "member",
    view = "edit"
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

execute.view{
  module = "member",
  view = "_show",
  params = { member = app.session.member }
}


slot.select("title", function()
  if app.session.member then
    execute.view{
      module = "member_image",
      view = "_show",
      params = {
        member = app.session.member,
        image_type = "avatar"
      }
    }
  end
end)

slot.select("title", function()
  ui.container{
    attr = { class = "lang_chooser" },
    content = function()
      for i, lang in ipairs{"en", "de", "eo"} do
        ui.link{
          content = function()
            ui.image{
              static = "lang/" .. lang .. ".png",
              attr = { style = "margin-left: 0.5em;", alt = lang }
            }
          end,
          text = _('Select language "#{langcode}"', { langcode = lang }),
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

if app.session.member then
	app.html_title.title = app.session.member.name
end


slot.select("actions", function()

  if app.session.member then
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
          ui.image{ static = "icons/16/wrench.png" }
          slot.put(_"Settings")
      end,
      module = "member",
      view = "settings"
    }
    if config.download_dir then
      ui.link{
        content = function()
            ui.image{ static = "icons/16/database_save.png" }
            slot.put(_"Download")
        end,
        module = "index",
        view = "download"
      }
    end 
  end
end)

util.help("index.index", _"Home")

execute.view{
  module = "member",
  view = "_show",
  params = {
    member = app.session.member,
    show_as_homepage = true
  }
}

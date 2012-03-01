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

if app.session.member_id then
  util.help("index.index", _"Home")

  execute.view{
    module = "member",
    view = "_show",
    params = {
      member = app.session.member,
      show_as_homepage = true
    }
  }

elseif config.public_access then
  if config.motd_public then
    local help_text = config.motd_public
    ui.container{
      attr = { class = "wiki motd" },
      content = function()
        slot.put(format.wiki_text(help_text))
      end
    }
  end
  
  execute.view{ module = "unit", view = "_list" }
  
else

  ui.tag{ tag = "p", content = _"Closed user group, please login to participate." }

  ui.form{
  attr = { class = "login" },
  module = 'index',
  action = 'login',
  routing = {
    ok = {
      mode   = 'redirect',
      module = param.get("redirect_module") or "index",
      view = param.get("redirect_view") or "index",
      id = param.get("redirect_id"),
    },
    error = {
      mode   = 'forward',
      module = 'index',
      view   = 'login',
    }
  },
  content = function()
    ui.field.text{
      attr = { id = "username_field" },
      label     = _'login name',
      html_name = 'login',
      value     = ''
    }
    ui.script{ script = 'document.getElementById("username_field").focus();' }
    ui.field.password{
      label     = _'Password',
      html_name = 'password',
      value     = ''
    }
    ui.submit{
      text = _'Login'
    }
  end
}

end


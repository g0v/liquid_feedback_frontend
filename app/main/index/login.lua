local warning_text = _"Some JavaScript based functions (voting in particular) will not work.\nFor this beta, please use a current version of Firefox, Safari, Chrome, Opera(?), Konqueror or another (more) standard compliant browser.\nAlternative access without JavaScript will be available soon."

ui.script{ static = "js/browser_warning.js" }
ui.script{ script = "checkBrowser(" .. encode.json(_"Your web browser is not fully supported yet." .. " " .. warning_text:gsub("\n", "\n\n")) .. ");" }

ui.tag{
  tag = "noscript",
  content = function()
    slot.put(_"JavaScript is disabled or not available." .. " " .. encode.html_newlines(warning_text))
  end
}

slot.put_into("title", encode.html(config.app_title))
app.html_title.title = _"Login"

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

if config.motd_public then
  local help_text = config.motd_public
  ui.container{
    attr = { class = "wiki motd" },
    content = function()
      slot.put(format.wiki_text(help_text))
    end
  }
end

ui.tag{
  tag = 'p',
  content = _'You need to be logged in, to use all features of this system.'
}

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

if config.auth_openid_enabled then
  ui.form{
    attr = { class = "login" },
    module = 'openid',
    action = 'initiate',
    routing = {
      default = {
        mode   = 'forward',
        module = 'index',
        view   = 'login',
      }
    },
    content = function()
      ui.field.text{
        label     = _'OpenID',
        html_name = 'openid_identifier',
        value     = ''
      }
      ui.submit{
        text = _'OpenID Login'
      }
    end
  }
end

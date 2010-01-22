local warning_text = _"Some JavaScript based functions (voting in particular) will not work.\nFor this beta, please use a current version of Firefox, Safari, Opera(?), Konqueror or another (more) standard compliant browser.\nAlternative access without JavaScript will be available soon."

ui.script{ static = "js/browser_warning.js" }
ui.script{ script = "checkBrowser(" .. encode.json(_"Your web browser is not fully supported yet." .. " " .. warning_text:gsub("\n", "\n\n")) .. ");" }

ui.tag{
  tag = "noscript",
  content = function()
    slot.put(_"JavaScript is disabled or not available." .. " " .. encode.html_newlines(warning_text))
  end
}

slot.put_into("title", encode.html(config.app_title))

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



ui.tag{
  tag = 'p',
  content = _'You need to be logged in, to use this system.'
}

ui.form{
  attr = { class = "login" },
  module = 'index',
  action = 'login',
  routing = {
    ok = {
      mode   = 'redirect',
      module = 'index',
      view   = 'index'
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


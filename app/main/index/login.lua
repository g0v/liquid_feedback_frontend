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

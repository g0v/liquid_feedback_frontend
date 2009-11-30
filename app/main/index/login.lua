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
      label     = _'Username',
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

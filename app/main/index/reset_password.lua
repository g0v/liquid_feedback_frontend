ui.title(_"Reset password")

ui.actions(function()
  ui.link{
    content = function()
      ui.image{ static = "icons/16/cancel.png" }
      slot.put(_"Cancel password reset")
    end,
    module = "index",
    view = "login"
  }
end)


local secret = param.get("secret")

if not secret then
  ui.tag{
    tag = 'p',
    content = _'Please enter your login name! You will receive an email with a link to reset your password. Note that your login name might be distinct from your screen name!'
  }
  ui.form{
    attr = { class = "vertical" },
    module = "index",
    action = "reset_password",
    content = function()
      ui.field.text{
        label = _"Login name",
        name = "login"
      }
      ui.submit{ text = _"Request password reset link" }
      slot.put("&nbsp;&nbsp;")
      ui.link{ module = "index", view = "send_login", text = _"Forgot login name?" }
    end
  }

else

  ui.form{
    attr = { class = "vertical" },
    module = "index",
    action = "reset_password",
    routing = {
      ok = {
        mode = "redirect",
        module = "index",
        view = "login"
      }
    },
    content = function()
      ui.tag{
        tag = 'p',
        content = _'Please enter the email reset code you have received:'
      }
      ui.field.text{
        label = _"Reset code",
        name = "secret",
        value = secret
      }
      ui.tag{
        tag = 'p',
        content = _'Please enter your new password twice:'
      }
      ui.field.password{
        label = "New password",
        name = "password1"
      }
      ui.field.password{
        label = "New password (repeat)",
        name = "password2"
      }
      ui.submit{ text = _"Set new password" }
    end
  }

end
ui.tag{
  tag = "noscript",
  content = function()
    slot.put(_"JavaScript is disabled or not available.")
  end
}

app.html_title.title = _"Login"
ui.title(_"Login")

ui.actions(function()
  if app.session.member == nil then
    ui.link{
      text   = _"Registration",
      module = "index",
      view   = "register"
    }
    slot.put(" &middot; ")
    ui.link{
      module = "index",
      view = "reset_password",
      text = _"Forgot password?"
    }
    if config.send_login then
      slot.put(" &middot; ")
      ui.link{
        module = "index",
        view = "send_login",
        text = _"Forgot login name?"
      }
    end
  end
end)

if app.session:has_access("anonymous") then
  ui.tag{
    tag = "p",
    content = _"You need to be logged in, to use all features of this system."
  }
else
  ui.tag{ tag = "p", content = _"Closed user group, please login to participate." }
end

-- redirect after successful login
local redirect_module = param.get("redirect_module")
local redirect_view   = param.get("redirect_view")
local redirect_id     = param.get("redirect_id")
local redirect_params = param.get_unserialize("redirect_params")

if not redirect_module or not redirect_view or (
  redirect_module == "index" and (redirect_view == "login" or redirect_view == "reset_password")
) then
  redirect_module = "index"
  redirect_view   = "index"
  redirect_id     = nil
  redirect_params = nil
end

ui.link{
  text   = _"Login with g0v hub",
  module = 'auth'
}

ui.form{
  attr = { class = "login" },
  module = "index",
  action = "login",
  routing = {
    ok = {
      mode   = "redirect",
      module = redirect_module,
      view   = redirect_view,
      id     = redirect_id,
      params = redirect_params
    }
  },
  content = function()
    ui.field.text{
      attr = { id = "username_field" },
      label     = _"Login name",
      html_name = "login",
      value     = ""
    }
    ui.script{ script = 'document.getElementById("username_field").focus();' }
    ui.field.password{
      label     = _"Password",
      html_name = "password",
      value     = ""
    }
    ui.submit{
      text = _"Login"
    }
  end
}

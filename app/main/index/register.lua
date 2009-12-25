slot.put_into("title", _"Registration")

slot.select("actions", function()
  ui.link{
    content = function()
        ui.image{ static = "icons/16/cancel.png" }
        slot.put(_"Cancel")
    end,
    module = "index",
    view = "index"
  }
end)

local code = param.get("code")
local name = param.get("name")
local login = param.get("login")

ui.form{
  attr = { class = "login" },
  module = 'index',
  action = 'register',
  params = {
    code = code,
    name = name,
    login = login
  },
  content = function()

    if not code then
      ui.tag{
        tag = "p",
        content = _"Please enter the invite code you've received."
      }
      ui.field.text{
        label     = _'Invite code',
        name = 'code',
      }

    elseif not name then
      ui.tag{
        tag = "p",
        content = _"Please choose a name, i.e. your real name or your nick name. This name will be shown to others to identify you. You CAN'T change this name later, so please choose it wisely!"
      }
      ui.field.text{
        label     = _'Name',
        name      = 'name',
        value     = param.get("name")
      }

    elseif not login then
      ui.tag{
        tag = "p",
        content = _"Please choose a login name. This name will not be shown to others and is used only by you to login into the system. The login name is case sensitive."
      }
      ui.field.text{
        label     = _'Login name',
        name      = 'login',
        value     = param.get("login")
      }

    else
      ui.field.text{
        label     = _'Name',
        name      = 'name',
        value     = param.get("name"),
        readonly = true
      }
      ui.field.text{
        label     = _'Login name',
        name      = 'login',
        value     = param.get("login"),
        readonly = true
      }
      ui.tag{
        tag = "p",
        content = _"Please choose a password and enter it twice. The password is case sensitive."
      }
      ui.field.password{
        label     = _'Password',
        name      = 'password1',
      }
      ui.field.password{
        label     = _'Password (repeat)',
        name      = 'password2',
      }

    end

    ui.submit{
      text = _'Register'
    }

  end
}



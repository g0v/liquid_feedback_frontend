local code = param.get("code")
local notify_email = param.get("notify_email")
local name = param.get("name")
local login = param.get("login")

ui.form{
  attr = { class = "vertical" },
  module = 'index',
  action = 'register',
  params = {
    code = code,
    notify_email = notify_email,
    name = name,
    login = login,
    password1 = password1,
    password2 = password2
  },
  content = function()

    local member
    if code then
      member = Member:new_selector()
        :add_where{ "invite_code = ?", code }
        :add_where{ "activated ISNULL" }
        :optional_object_mode()
        :for_update()
        :exec()
    end

    if not member then

      -- Step 1 --

      ui.title(_"Registration")
      ui.actions(function()
        ui.link{
          content = function()
              slot.put(_"Cancel registration")
          end,
          module = "index",
          view = "index"
        }
      end)

      ui.tag{
        tag = "p",
        content = _"Please enter the invite code you've received."
      }
      if config.register_without_invite_code then
        ui.tag{
          tag = "p",
          attr = { style = "font-style:italic" },
          content = _"In this installation registration is also possible without an invite code. Therefor please just leave the field empty."
        }
      end
      ui.field.text{
        label = _'Invite code',
        name  = 'code',
        value = param.get("invite")
      }
      ui.submit{
        text = _'Proceed with registration'
      }

    else

      -- Step 2 --

      ui.title(_"Registration")
      ui.actions(function()
        ui.link{
          content = function()
            slot.put(_"Back")
          end,
          module = "index",
          view = "register",
          params = {
            invite = code
          }
        }
        slot.put(" &middot; ")
        ui.link{
          content = function()
            slot.put(_"Cancel registration")
          end,
          module = "index",
          view = "index"
        }
      end)

      ui.field.hidden{ name = "step2", value = 1 }

      -- profile
      ui.tag{
        tag = "p",
        content = _"This invite key is connected with the following information:"
      }
      execute.view{ module = "member", view = "_profile", params = { member = member, include_private_data = true } }

      -- email
      if not config.locked_profile_fields.notify_email then
        ui.tag{
          tag = "p",
          content = _"Please enter your email address. This address will be used for automatic notifications (if you request them) and in case you've lost your password. This address will not be published. After registration you will receive an email with a confirmation link."
        }
        ui.field.text{
          label     = _'Email address',
          name      = 'notify_email',
          value     = param.get("notify_email") or member.notify_email
        }
      end

      -- screen name
      if not config.locked_profile_fields.name then
        ui.tag{
          tag = "p",
          content = _"Please choose a name, i.e. your real name or your nick name. This name will be shown to others to identify you."
        }
        ui.field.text{
          label     = _'Screen name',
          name      = 'name',
          value     = param.get("name") or member.name
        }
      end

      -- login
      if not config.locked_profile_fields.login then
        ui.tag{
          tag = "p",
          content = _"Please choose a login name. This name will not be shown to others and is used only by you to login into the system. The login name is case sensitive."
        }
        ui.field.text{
          label     = _'Login name',
          name      = 'login',
          value     = param.get("login") or member.login
        }
      end

      -- password
      ui.tag{
        tag = "p",
        content = _"Please choose a password and enter it twice. The password is case sensitive and has to be at least 8 characters long."
      }
      ui.field.password{
        label     = _'Password',
        name      = 'password1',
        value     = param.get('password1')
      }
      ui.field.password{
        label     = _'Password (repeat)',
        name      = 'password2',
        value     = param.get('password2')
      }

      slot.put("<br />")

      -- terms of use
      ui.container{
        attr = { class = "wiki use_terms" },
        content = function()
          if config.use_terms_html then
            slot.put(config.use_terms_html)
          else
            slot.put(format.wiki_text(config.use_terms))
          end
        end
      }

      -- checkbox(es) for the terms of use
      for i, checkbox in ipairs(config.use_terms_checkboxes) do
        slot.put("<br />")
        ui.tag{
          tag = "div",
          content = function()
            ui.tag{
              tag = "input",
              attr = {
                type = "checkbox",
                id = "use_terms_checkbox_" .. checkbox.name,
                name = "use_terms_checkbox_" .. checkbox.name,
                value = "1",
                class = "left",
                checked = param.get("use_terms_checkbox_" .. checkbox.name, atom.boolean) and "checked" or nil
              }
            }
            slot.put("&nbsp;")
            ui.tag{
              tag = "label",
              attr = { ['for'] = "use_terms_checkbox_" .. checkbox.name },
              content = function() slot.put(checkbox.html) end
            }
          end
        }
      end

      slot.put("<br />")

      ui.submit{
        text = _'Activate account'
      }

    end
  end
}



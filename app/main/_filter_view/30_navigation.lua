slot.put_into("app_name", config.app_title)

slot.select('navigation', function()

  if config.public_access or app.session.member_id then
    ui.link{
      text   = _"Home",
      module = 'index',
      view   = 'index'
    }
  else
    ui.link{
      text   = _"Login",
      module = 'index',
      view   = 'index'
    }
  end

  if app.session.member then

    if not config.single_unit_id then
      ui.link{
        text   = _"Units",
        module = 'unit',
        view   = 'list'
      }
    else
      ui.link{
        text   = _"Areas",
        module = 'unit',
        view   = 'show',
        id = config.single_unit_id
      }
    end
  end

  if config.public_access and app.session.member == nil then
    ui.link{
      text   = _"Login",
      module = 'index',
      view   = 'login',
      params = {
        redirect_module = request.get_module(),
        redirect_view = request.get_view(),
        redirect_id = param.get_id()
      }
    }
  end

  if app.session.member == nil then
    ui.link{
      text   = _"Registration",
      module = 'index',
      view   = 'register'
    }
    ui.link{
      text   = _"Reset password",
      module = 'index',
      view   = 'reset_password'
    }
    ui.link{
      text   = _"About / Impressum",
      module = 'index',
      view   = 'about'
    }
  else 

    ui.link{
      text   = _"Timeline",
      module = "timeline",
      view   = "index"
    }

    ui.link{
      text   = _"Members",
      module = 'member',
      view   = 'list',
      params = { member_list = "newest" }
    }

    ui.link{
      text   = _"Contacts",
      module = 'contact',
      view   = 'list'
    }

    ui.link{
      text = (_"Settings"),
      module = "member",
      view = "settings"
    }

    ui.link{
      text   = _"About",
      module = 'index',
      view   = 'about'
    }

    if app.session.member.admin then

      slot.put(" ")

      ui.link{
        attr   = { class = { "admin_only" } },
        text   = _"Admin",
        module = 'admin',
        view   = 'index'
      }

    end
  end

end)

if config.app_logo then
  slot.select("logo", function()
    ui.image{ static = config.app_logo }
  end)
end

execute.inner()

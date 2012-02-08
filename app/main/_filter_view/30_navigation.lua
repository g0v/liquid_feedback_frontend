slot.put_into("app_name", config.app_title)

slot.select('navigation', function()

  if app.session.member then
    ui.link{
--      image  = { static = "icons/16/house.png" },
      text   = _"Home",
      module = 'index',
      view   = 'index'
    }
  end

  if app.session.member or config.public_access then

    if not config.single_unit_id then
      ui.link{
--        image  = { static = "icons/16/package.png" },
        text   = _"Units",
        module = 'unit',
        view   = 'list'
      }
    else
      ui.link{
--        image  = { static = "icons/16/package.png" },
        text   = _"Areas",
        module = 'area',
        view   = 'list'
      }
    end
  end

  if app.session.member == nil then
    ui.link{
--      image  = { static = "icons/16/key.png" },
      text   = _"Login",
      module = 'index',
      view   = 'login',
      params = {
        redirect_module = request.get_module(),
        redirect_view = request.get_view(),
        redirect_id = param.get_id()
      }
    }
    ui.link{
--      image  = { static = "icons/16/book_edit.png" },
      text   = _"Registration",
      module = 'index',
      view   = 'register'
    }
    ui.link{
--      image  = { static = "icons/16/key_forgot.png" },
      text   = _"Reset password",
      module = 'index',
      view   = 'reset_password'
    }
    ui.link{
--      image  = { static = "icons/16/information.png" },
      text   = _"About / Impressum",
      module = 'index',
      view   = 'about'
    }
  else 

    ui.link{
--      image  = { static = "icons/16/time.png" },
      text   = _"Timeline",
      module = "timeline",
      view   = "index"
    }

    ui.link{
--      image  = { static = "icons/16/group.png" },
      text   = _"Members",
      module = 'member',
      view   = 'list',
      params = { member_list = "newest" }
    }

    ui.link{
--      image  = { static = "icons/16/book_edit.png" },
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
--      image  = { static = "icons/16/information.png" },
      text   = _"About",
      module = 'index',
      view   = 'about'
    }

    if app.session.member.admin then

      slot.put(" ")

      ui.link{
        attr   = { class = { "admin_only" } },
--        image  = { static = "icons/16/cog.png" },
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

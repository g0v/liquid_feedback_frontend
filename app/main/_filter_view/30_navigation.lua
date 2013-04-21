slot.select('navigation', function()

  ui.link{
    content = function()
      ui.tag{ attr = { class = "logo" }, content = _"Pirate Feedback" }
      slot.put(" &middot; ")
      ui.tag{ content = config.instance_name }
    end,
    module = 'index',
    view   = 'index'
  }

  -- language
  ui.tag{
    tag = "ul",
    attr = { id = "language_menu" },
    content = function()
      ui.tag{
        tag = "li",
        content = function()
          ui.link{
            module = "index",
            view = "menu",
            content = function()
              ui.tag{ content = _"Language" }
            end
          }
          execute.view{ module = "index", view = "_menu" }
        end
      }
    end
  }

  -- search
  if app.session:has_access("anonymous") then
    ui.link{
      content = _"Search",
      module = 'index',
      view   = 'search'
    }
  end

end)

slot.select('navigation_right', function()

  if app.session.member_id then

    ui.link{
      text   = _"Logout",
      module = 'index',
      action = 'logout',
      routing = {
        default = {
          mode = "redirect",
          module = "index",
          view = "index"
        }
      }
    }

    if app.session.member.admin then
      ui.link{
        text   = _"Admin",
        module = 'admin',
        view   = 'index'
      }
    end

    ui.link{
      text   = _"Settings",
      module = "member",
      view = "settings"
    }

    ui.link{
      content = _"Contacts",
      module = 'contact',
      view   = 'list'
    }

    ui.link{
      text = _"Profile",
      module = "member",
      view = "show",
      id = app.session.member_id,
      attr = { title = _"Profile" },
      content = function()
        execute.view{
          module = "member_image",
          view = "_show",
          params = {
            member = app.session.member,
            image_type = "avatar",
            show_dummy = true,
            class = "micro_avatar"
          }
        }
        ui.tag{ content = app.session.member.name }
      end
    }

  else

    if app.session:has_access("anonymous") then
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

  end

end)

slot.select("footer", function()
  ui.link{
    text   = _"About site",
    module = 'index',
    view   = 'about'
  }
  slot.put(" &middot; ")
  ui.link{
    text   = _"Use terms",
    module = 'index',
    view   = 'usage_terms'
  }
end)

execute.inner()

slot.put_into("app_name", config.app_title)

-- display navigation only, if user is logged in
if app.session.member == nil then
  slot.select('navigation', function()
    ui.link{
      content = function()
        ui.image{ static = "icons/16/key.png" }
        slot.put(_"Login")
      end,
      module = 'index',
      view = 'login'
    }
    ui.link{
      content = function()
        ui.image{ static = "icons/16/book_edit.png" }
        slot.put(_"Registration")
      end,
      module = 'index',
      view = 'register'
    }
    ui.link{
      content = function()
        ui.image{ static = "icons/16/key_forgot.png" }
        slot.put(_"Reset password")
      end,
      module = 'index',
      view = 'reset_password'
    }
    ui.link{
      content = function()
        ui.image{ static = "icons/16/information.png" }
        slot.put('About / Impressum')
      end,
      module = 'index',
      view = 'about'
    }
  end)
  execute.inner()
  return
end

slot.select('navigation', function()

  ui.link{
    content = function()
      ui.image{ static = "icons/16/house.png" }
      slot.put(_"Home")
    end,
    module = 'index',
    view = 'index'
  }

  local setting_key = "liquidfeedback_frontend_timeline_current_options"
  local setting = Setting:by_pk(app.session.member.id, setting_key)

  timeline_params = {}
  if setting then
    for event_ident, filter_idents in setting.value:gmatch("(%S+):(%S+)") do
      timeline_params["option_" .. event_ident] = true
      if filter_idents ~= "*" then
        for filter_ident in filter_idents:gmatch("([^\|]+)") do
          timeline_params["option_" .. event_ident .. "_" .. filter_ident] = true
        end
      end
    end
  end

  timeline_params.date = param.get("date") or today

  ui.link{
    content = function()
      ui.image{ static = "icons/16/time.png" }
      slot.put(_"Timeline")
    end,
    module = "timeline",
    action = "update"
--    params = timeline_params
  }

  ui.link{
    content = function()
      ui.image{ static = "icons/16/package.png" }
      slot.put(_"Areas")
    end,
    module = 'area',
    view = 'list'
  }

  ui.link{
    content = function()
      ui.image{ static = "icons/16/group.png" }
      slot.put(_"Members")
    end,
    module = 'member',
    view = 'list'
  }

  ui.link{
    content = function()
      ui.image{ static = "icons/16/book_edit.png" }
      slot.put(_"Contacts")
    end,
    module = 'contact',
    view = 'list'
  }

  ui.link{
    content = function()
      ui.image{ static = "icons/16/information.png" }
      slot.put(_"About")
    end,
    module = 'index',
    view = 'about'
  }

  if app.session.member.admin then

    slot.put(" ")

    ui.link{
      attr = { class = { "admin_only" } },
      content = function()
        ui.image{ static = "icons/16/cog.png" }
        slot.put(_'Admin')
      end,
      module = 'admin',
      view = 'index'
    }

  end

end)

if config.app_logo then
  slot.select("logo", function()
    ui.image{ static = config.app_logo }
  end)
end

execute.inner()



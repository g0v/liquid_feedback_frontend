slot.put_into("app_name", config.app_title)

-- display navigation only, if user is logged in
if app.session.member == nil then
  slot.select('navigation', function()
    ui.link{
      content = function()
        ui.image{ static = "icons/16/key.png" }
        slot.put('Login')
      end,
      module = 'index',
      view = 'login'
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
        slot.put(_'Home')
      end,
      module = 'index',
      view = 'index'
    }

    ui.link{
      content = function()
        ui.image{ static = "icons/16/package.png" }
        slot.put(_'Areas')
      end,
      module = 'area',
      view = 'list'
    }

    ui.link{
      content = function()
        ui.image{ static = "icons/16/group.png" }
        slot.put(_'Members')
      end,
      module = 'member',
      view = 'list'
    }

    ui.link{
      content = function()
        ui.image{ static = "icons/16/book_edit.png" }
        slot.put(_'Contacts')
      end,
      module = 'contact',
      view = 'list'
    }

    ui.link{
      content = function()
        ui.image{ static = "icons/16/information.png" }
        slot.put(_'About')
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

execute.inner()



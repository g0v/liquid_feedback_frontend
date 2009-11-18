if app.session.member == nil then
  execute.inner()
  return
end

slot.select('logout_button', function()
  ui.link{
    content = function()
      ui.image{ static = "icons/16/stop.png" }
      slot.put(_'Logout')
    end,
    module = 'index',
    action = 'logout'
  }
end)

execute.inner()

if app.session.member == nil then
  execute.inner()
  return
end

slot.select('logout_button', function()
  ui.link{
    image  = { static = "icons/16/stop.png" },
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
end)

execute.inner()

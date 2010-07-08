slot.put_into("title", _"Change your name")

slot.select("actions", function()
  ui.link{
    content = function()
        ui.image{ static = "icons/16/cancel.png" }
        slot.put(_"Cancel")
    end,
    module = "member",
    view = "settings"
  }
end)

util.help("member.settings.name", _"Change name")

ui.form{
  attr = { class = "vertical" },
  module = "member",
  action = "update_name",
  routing = {
    ok = {
      mode = "redirect",
      module = "index",
      view = "index"
    }
  },
  content = function()
    ui.field.text{ label = _"Name", name = "name", value = app.session.member.name }
    ui.submit{ value = _"Change name" }
  end
}

slot.put_into("title", _"Edit my page")

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

ui.form{
  record = app.session.member,
  attr = { class = "vertical" },
  module = "member",
  action = "update",
  routing = {
    ok = {
      mode = "redirect",
      module = "index",
      view = "index"
    }
  },
  content = function()
    ui.field.text{ label = _"Name", name = "name" }
    ui.submit{ value = _"Save" }
  end
}
slot.put_into("title", _"Upload avatar")

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
  attr = { 
    class = "vertical",
    enctype = 'multipart/form-data'
  },
  module = "member",
  action = "update_avatar",
  routing = {
    ok = {
      mode = "redirect",
      module = "index",
      view = "index"
    }
  },
  content = function()
    ui.field.image{ field_name = "avatar", label = _"Avatar" }
    ui.submit{ value = _"Save" }
  end
}
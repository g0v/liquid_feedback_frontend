slot.put_into("title", _"Add new draft")

local initiative_id = param.get("initiative_id")

ui.form{
  attr = { class = "vertical" },
  module = "draft",
  action = "add",
  params = { initiative_id = initiative_id },
  routing = {
    default = {
      mode = "redirect",
      module = "initiative",
      view = "show",
      id = initiative_id
    }
  },
  content = function()

    ui.field.text{ label = _"Author", value = app.session.member.name, readonly = true }
    ui.field.text{ label = _"Content", name = "content", multiline = true }

    ui.submit{ text = _"Save" }
  end
}

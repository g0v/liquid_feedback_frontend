slot.put_into("title", _"Add new draft")

local initiative = Initiative:by_id(param.get("initiative_id"))

ui.form{
  record = initiative.current_draft,
  attr = { class = "vertical" },
  module = "draft",
  action = "add",
  params = { initiative_id = initiative.id },
  routing = {
    default = {
      mode = "redirect",
      module = "initiative",
      view = "show",
      id = initiative.id
    }
  },
  content = function()

    ui.field.text{ label = _"Author", value = app.session.member.name, readonly = true }
    ui.field.text{
      label = _"Content",
      name = "content",
      multiline = true,
      attr = { style = "height: 50ex;" }
   }

    ui.submit{ text = _"Save" }
  end
}

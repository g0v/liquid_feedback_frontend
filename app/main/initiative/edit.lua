local initiative = Initiative:by_id(param.get_id())

slot.put_into("title", _"Edit initiative")

ui.form{
  record = initiative,
  module = "initiative",
  action = "update",
  id = initiative.id,
  attr = { class = "vertical" },
  routing = {
    default = {
      mode = "redirect",
      module = "initiative",
      view = "show",
      id = initiative.id
    }
  },
  content = function()
    ui.field.text{ label = _"Discussion URL",  name = "discussion_url" }
    ui.submit{ text = _"Save" }
  end
}
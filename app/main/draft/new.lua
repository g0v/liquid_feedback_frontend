slot.put_into("title", _"Edit draft")

local initiative = Initiative:by_id(param.get("initiative_id"))

slot.select("actions", function()
  ui.link{
    content = function()
        ui.image{ static = "icons/16/cancel.png" }
        slot.put(_"Cancel")
    end,
    module = "initiative",
    view = "show",
    id = initiative.id
  }
end)

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
    ui.field.select{
      label = _"Wiki engine",
      name = "formatting_engine",
      foreign_records = {
        { id = "rocketwiki", name = "RocketWiki" },
        { id = "compat", name = _"Traditional wiki syntax" }
      },
      foreign_id = "id",
      foreign_name = "name"
    }
    ui.field.text{
      label = _"Content",
      name = "content",
      multiline = true,
      attr = { style = "height: 50ex;" }
   }

    ui.submit{ text = _"Save" }
  end
}

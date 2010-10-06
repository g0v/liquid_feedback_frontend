local initiative_id = param.get("initiative_id")

slot.put_into("title", _"Add new suggestion")

slot.select("actions", function()
  ui.link{
    content = function()
        ui.image{ static = "icons/16/cancel.png" }
        slot.put(_"Cancel")
    end,
    module = "initiative",
    view = "show",
    id = initiative_id,
    params = { tab = "suggestions" }
  }
end)

ui.form{
  module = "suggestion",
  action = "add",
  params = { initiative_id = initiative_id },
  routing = {
    default = {
      mode = "redirect",
      module = "initiative",
      view = "show",
      id = initiative_id,
      params = { tab = "suggestions" }
    }
  },
  attr = { class = "vertical" },
  content = function()
    local supported = Supporter:by_pk(initiative_id, app.session.member.id) and true or false
    if not supported then
      ui.field.text{
        attr = { class = "warning" },
        value = _"You are currently not supporting this initiative directly. By adding suggestions to this initiative you will automatically become a potential supporter."
      }
    end
    ui.field.text{ label = _"Title (80 chars max)",        name = "name" }
    ui.field.text{ label = _"Description", name = "description", multiline = true, attr={id="suggestion_description"}}
    ui.field.select{
      label = _"Degree",
      name = "degree",
      foreign_records = {
        { id =  1, name = _"should"},
        { id =  2, name = _"must"},
      },
      foreign_id = "id",
      foreign_name = "name"
    }
    ui.submit{ text = _"Commit suggestion" }
  end
}

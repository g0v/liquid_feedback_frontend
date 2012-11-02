local initiative_id = param.get("initiative_id")

ui.title(_"Add new suggestion")

ui.actions(function()
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
    ok = {
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

    ui.field.text{ label = _"Title (80 chars max)", name = "name" }

    ui.wikitextarea("content", _"Description")

    ui.submit{ text = _"Commit suggestion" }

  end
}

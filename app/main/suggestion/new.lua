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

    if param.get("preview") then

      ui.field.text{ label = _"Title", value = param.get("name"), readonly = true }

      ui.container{
        attr = { class = "suggestion_content wiki initiative_head" },
        content = function()
          slot.put( format.wiki_text(param.get("content"), param.get("formatting_engine")) )
        end
      }

      ui.submit{ text = _"Commit suggestion" }
      slot.put("<br /><br /><br />")

    end

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

    ui.field.text{
      label = _"Title (80 chars max)",
      name = "name",
      value = param.get("name")
    }

    ui.wikitextarea("content", _"Description")

    ui.submit{ name = "preview", text = _"Preview" }
    -- hack for the additional submit button, because ui.submit does not allow to set the class attribute
    ui.tag{ tag = "input", attr = { type = "submit", class = "additional", value = _"Commit suggestion" } }

  end
}

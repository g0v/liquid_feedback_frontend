local initiative = Initiative:by_id(param.get("initiative_id"))

app.html_title.title = _"Edit draft"
app.html_title.subtitle = _("Initiative i#{id}", { id = initiative.id })

ui.title(function()
  ui.link{
    content = initiative.issue.area.unit.name,
    module = "unit",
    view = "show",
    id = initiative.issue.area.unit.id
  }
  slot.put(" &middot; ")
  ui.link{
    content = initiative.issue.area.name,
    module = "area",
    view = "show",
    id = initiative.issue.area.id
  }
  slot.put(" &middot; ")
  ui.link{
    content = initiative.issue.policy.name .. " #" .. initiative.issue.id,
    module = "issue",
    view = "show",
    id = initiative.issue.id
  }
  slot.put(" &middot; ")
  ui.link{
    content = _("Initiative i#{id}: #{name}", { id = initiative.id, name = initiative.name }),
    module = "initiative",
    view = "show",
    id = initiative.id
  }
  slot.put(" &middot; ")
  ui.tag{
    content = _"Edit draft"
  }
end)

ui.actions(function()
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
    ok = {
      mode = "redirect",
      module = "initiative",
      view = "show",
      id = initiative.id
    }
  },
  content = function()

    slot.put("<br />")

    if param.get("preview") then

      ui.container{ attr = { class = "initiative_head" }, content = function()

        -- title
        ui.container{
          attr = { class = "title" },
          content = _("Initiative i#{id}: #{name}", { id = initiative.id, name = initiative.name })
        }

        -- draft content
        ui.container{
          attr = { class = "draft_content wiki" },
          content = function()
            slot.put(format.wiki_text(param.get("content"), param.get("formatting_engine")))
          end
        }

      end }

      ui.submit{ text = _"Save" }
      slot.put("<br /><br /><br />")

    end

    ui.wikitextarea("content", _"Content")

    ui.submit{ name = "preview", text = _"Preview" }
    -- hack for the additional submit button, because ui.submit does not allow to set the class attribute
    ui.tag{ tag = "input", attr = { type = "submit", class = "additional", value = _"Save" } }

  end
}

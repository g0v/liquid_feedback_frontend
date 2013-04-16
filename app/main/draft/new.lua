local initiative = Initiative:by_id(param.get("initiative_id"))

app.html_title.title = _"Edit draft"
app.html_title.subtitle = _("Initiative i#{id}", { id = initiative.id })

ui.title(_"Edit draft", initiative.issue.area.unit, initiative.issue.area, initiative.issue, initiative)

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

slot.put("<br />")

if param.get("preview") then

  ui.container{ attr = { class = "initiative_head" }, content = function()

    -- title
    ui.container{
      attr = { class = "title" },
      content = _("Initiative i#{id}: #{name}", { id = initiative.id, name = param.get("name") })
    }

    -- draft content
    ui.container{
      attr = { class = "draft_content wiki" },
      content = function()
        slot.put(format.wiki_text(param.get("content"), param.get("formatting_engine")))
      end
    }

  end }

elseif param.get("diff") then

  local diff1 = util.diff(initiative.current_draft.name,    param.get("name"))
  local diff2 = util.diff(initiative.current_draft.content, param.get("content"))
  if not diff1 and not diff2 then
    slot.put_into("warning", _"The versions do not differ.")
  end

end

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

    if param.get("preview") then
      ui.submit{ name = "diff", text = _"Diff" }
      ui.submit{ attr = { class = "additional" }, text = _"Save" }
      slot.put("<br /><br /><br />")
    elseif param.get("diff") then
      ui.submit{ name = "preview", text = _"Preview" }
      ui.submit{ attr = { class = "additional" }, text = _"Save" }
      slot.put("<br /><br /><br />")
    end

    ui.field.text{
      label = _"Title of initiative",
      name  = "name",
      attr = { maxlength = 256 },
      value = param.get("name")
    }

    ui.wikitextarea("content", _"Content")

    ui.submit{ name = "preview", text = _"Preview" }
    ui.submit{ attr = { class = "additional" }, name = "diff", text = _"Diff" }
    ui.submit{ attr = { class = "additional" }, text = _"Save" }

  end
}

ui.title(_"Edit draft")

local initiative = Initiative:by_id(param.get("initiative_id"))

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

    ui.field.text{ label = _"Unit", value = initiative.issue.area.unit.name, readonly = true }
    ui.field.text{ label = _"Area", value = initiative.issue.area.name, readonly = true }
    ui.field.text{
      label = _"Issue",
      value = _("#{policy_name} ##{issue_id}", { policy_name = initiative.issue.policy.name, issue_id = initiative.issue.id }),
      readonly = true
    }
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

local initiative_id = param.get("initiative_id")
local initiative = Initiative:by_id(initiative_id)

local side = param.get("side")

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
    content = _("Issue ##{id}", { id = initiative.issue.id }),
    module = "issue",
    view = "show",
    id = initiative.issue.id
  }
  slot.put(" &middot; ")
  if side == "pro" then
    slot.put(_"Add new argument pro for")
  else
    slot.put(_"Add new argument contra for")
  end
  slot.put(" ")
  ui.link{
    content = _("Initiative i#{id}: #{name}", { id = initiative.id, name = initiative.name }),
    module = "initiative",
    view = "show",
    id = initiative.id
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
    id = initiative_id,
    params = { tab = "arguments" }
  }
end)

ui.form{
  module = "argument",
  action = "add",
  params = { initiative_id = initiative_id, side = side },
  routing = {
    ok = {
      mode = "redirect",
      module = "initiative",
      view = "show",
      id = initiative_id,
      params = { tab = "arguments" }
    }
  },
  attr = { class = "vertical" },
  content = function()

    if param.get("preview") then

      ui.container{ attr = { class = "initiative_head" }, content = function()

        ui.container{ attr = { class = "title suggestion_title" }, content = param.get("name") }

        ui.container{ attr = { class = "content" }, content = function()

          ui.container{
            attr = { class = "initiator_names" },
            content = function()

              if app.session:has_access("all_pseudonymous") then
                ui.link{
                  content = function()
                    execute.view{
                      module = "member_image",
                      view = "_show",
                      params = {
                        member = app.session.member,
                        image_type = "avatar",
                        show_dummy = true,
                        class = "micro_avatar"
                      }
                    }
                  end,
                  module = "member", view = "show", id = app.session.member.id
                }
                slot.put(" ")
              end
              ui.link{
                text = app.session.member.name,
                module = "member", view = "show", id = app.session.member.id
              }

            end
          }

        end }

        ui.container{
          attr = { class = "draft_content wiki" },
          content = function()
            slot.put( format.wiki_text(param.get("content"), param.get("formatting_engine")) )
          end
        }

      end }

      ui.submit{ text = _"Commit argument" }
      slot.put("<br /><br /><br />")

    end

    ui.field.text{
      label = _"Title (80 chars max)",
      name = "name",
      value = param.get("name")
    }

    ui.wikitextarea("content", _"Description")

    ui.submit{ name = "preview", text = _"Preview" }
    -- hack for the additional submit button, because ui.submit does not allow to set the class attribute
    ui.tag{ tag = "input", attr = { type = "submit", class = "additional", value = _"Commit argument" } }

  end
}

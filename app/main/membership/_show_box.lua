local area = param.get("area", "table")

slot.select("interest", function()
  local membership = Membership:by_pk(area.id, app.session.member.id)

  ui.container{
    attr = { 
      class = "head",
      onclick = "document.getElementById('membership_content').style.display = 'block';"
    },
    content = function()
      if membership then
        ui.field.text{ value = _"You are member. [more]" }
      else
        ui.field.text{ value = _"You are not a member. [more]" }
      end
    end
  }

  ui.container{
    attr = { class = "content", id = "membership_content" },
    content = function()
      ui.container{
        attr = {
          class = "close",
          style = "cursor: pointer;",
          onclick = "document.getElementById('membership_content').style.display = 'none';"
        },
        content = _"X"
      }
      if membership then
        ui.link{
          content = _"Remove my membership",
          module = "membership",
          action = "update",
          params = { area_id = area.id, delete = true },
          routing = { default = { mode = "redirect", module = "area", view = "show", id = area.id } }
        }
        if membership.autoreject then
          ui.field.text{ value = _"Autoreject is on." }
          ui.link{
            content = _"Remove autoreject",
            module = "membership",
            action = "update",
            params = { area_id = area.id, autoreject = false },
            routing = { default = { mode = "redirect", module = "area", view = "show", id = area.id } }
          }
        else
          ui.field.text{ value = _"Autoreject is off." }
          ui.link{
            content = _"Set autoreject",
            module = "membership",
            action = "update",
            params = { area_id = area.id, autoreject = true },
            routing = { default = { mode = "redirect", module = "area", view = "show", id = area.id } }
          }
        end
      else
        ui.link{
          content = _"Add my membership to this area",
          module = "membership",
          action = "update",
          params = { area_id = area.id },
          routing = { default = { mode = "redirect", module = "area", view = "show", id = area.id } }
        }
      end
    end
  }
end)

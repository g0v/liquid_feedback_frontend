local area = param.get("area", "table")

local membership = Membership:by_pk(area.id, app.session.member.id)

slot.select("interest", function()

  if membership then
  
    ui.container{
      attr = { 
        class = "head head_active",
        onclick = "document.getElementById('membership_content').style.display = 'block';"
      },
      content = function()
        ui.image{
          static = "icons/16/user_green.png"
        }
        slot.put(_"You are member")
        ui.image{
          static = "icons/16/dropdown.png"
        }
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
          content = function()
            ui.image{ static = "icons/16/cross.png" }
          end
        }
        ui.link{
          text    = _"Remove my membership",
          module  = "membership",
          action  = "update",
          params  = { area_id = area.id, delete = true },
          routing = { default = { mode = "redirect", module = "area", view = "show", id = area.id } }
        }
        if membership.autoreject then
          ui.field.text{ value = _"Autoreject is on." }
          ui.link{
            text    = _"Remove autoreject",
            module  = "membership",
            action  = "update",
            params  = { area_id = area.id, autoreject = false },
            routing = { default = { mode = "redirect", module = "area", view = "show", id = area.id } }
          }
        else
          ui.field.text{ value = _"Autoreject is off." }
          ui.link{
            text    = _"Set autoreject",
            module  = "membership",
            action  = "update",
            params  = { area_id = area.id, autoreject = true },
            routing = { default = { mode = "redirect", module = "area", view = "show", id = area.id } }
          }
        end
      end
    }
  else
    ui.link{
      image  = { static = "icons/16/user_add.png" },
      text   = _"Become a member",
      module = "membership",
      action = "update",
      params = { area_id = area.id },
      routing = {
        default = {
          mode = "redirect",
          module = "area",
          view = "show",
          id = area.id
        }
      }
    }
  end

end)

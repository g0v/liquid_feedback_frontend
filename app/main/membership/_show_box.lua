local area = param.get("area", "table")

local membership = Membership:by_pk(area.id, app.session.member.id)

slot.select("interest", function()

  if membership then
  
    ui.container{
      attr = { 
        class = "head head_active",
      },
      content = function()
        ui.image{
          static = "icons/16/user_green.png"
        }
        slot.put(_"You are member")
      end
    }
    
    ui.link{
      image  = { static = "icons/16/cross.png" },
      text    = _"Withdraw membership",
      module  = "membership",
      action  = "update",
      params  = { area_id = area.id, delete = true },
      routing = { default = { mode = "redirect", module = "area", view = "show", id = area.id } }
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

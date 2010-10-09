
local initiative = param.get("initiative", "table")
local supporter = Supporter:by_pk(initiative.id, app.session.member.id)

local unique_string = multirand.string(16, '0123456789abcdef')


local partial = {
  routing = {
    default = {
      mode = "redirect",
      module = "initiative",
      view = "show_support",
      id = initiative.id
    }
  }
}

local routing = {
  default = {
    mode = "redirect",
    module = request.get_module(),
    view = request.get_view(),
    id = param.get_id_cgi(),
    params = param.get_all_cgi()
  }
}

if not initiative.issue.fully_frozen and not initiative.issue.closed then
  if supporter then
    if not supporter:has_critical_opinion() then
      ui.container{
        attr = {
          class = "head head_supporter",
          style = "cursor: pointer;",
          onclick = "document.getElementById('support_content_" .. unique_string .. "').style.display = 'block';"
        },
        content = function()
          ui.image{
            static = "icons/16/thumb_up_green.png"
          }
          if supporter.auto_support then
            slot.put(_"Your are supporter (Autosupport enabled)")
          else
            slot.put(_"Your are supporter")
          end
          ui.image{
            static = "icons/16/dropdown.png"
          }
        end
      }
    else
      ui.container{
        attr = {
          class = "head head_potential_supporter",
          style = "cursor: pointer;",
          onclick = "document.getElementById('support_content_" .. unique_string .. "').style.display = 'block';"
        },
        content = function()
          ui.image{
            static = "icons/16/thumb_up.png"
          }
          if supporter.auto_support then
            slot.put(_"Your are potential supporter (WARNING: Autosupport enabled)")
          else
            slot.put(_"Your are potential supporter")
          end
          ui.image{
            static = "icons/16/dropdown.png"
          }
        end
      }
    end
    ui.container{
      attr = { class = "content", id = "support_content_" .. unique_string .. "" },
      content = function()
        ui.container{
          attr = {
            class = "close",
            style = "cursor: pointer;",
            onclick = "document.getElementById('support_content_" .. unique_string .. "').style.display = 'none';"
          },
          content = function()
            ui.image{ static = "icons/16/cross.png" }
          end
        }
        if supporter then
          if config.auto_support then
            if supporter.auto_support then
              ui.link{
                image   = { static = "icons/16/cancel.png" },
                text    = _"Disable autosupport for this initiative",
                module  = "initiative",
                action  = "add_support",
                id      = initiative.id,
                routing = routing,
                partial = partial,
                params = { auto_support = false }
              }
            else
              ui.link{
                image   = { static = "icons/16/arrow_refresh.png" },
                text    = _"Enable autosupport for this initiative",
                module  = "initiative",
                action  = "add_support",
                id      = initiative.id,
                routing = routing,
                partial = partial,
                params = { auto_support = true }
              }
            end
          end
          ui.link{
            image   = { static = "icons/16/thumb_down_red.png" },
            text    = _"Remove my support from this initiative",
            module  = "initiative",
            action  = "remove_support",
            id      = initiative.id,
            routing = routing,
            partial = partial
          }
        else
        end
      end
    }
  else
    if not initiative.revoked then
      local params = param.get_all_cgi()
      params.dyn = nil
      ui.link{
        image   = { static = "icons/16/thumb_up_green.png" },
        text    = _"Support this initiative",
        module  = "initiative",
        action  = "add_support",
        id      = initiative.id,
        routing = routing,
        partial = partial
      }
    end
  end
end


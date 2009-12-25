
slot.select("support", function()
  local initiative = param.get("initiative", "table")
  local supporter = Supporter:by_pk(initiative.id, app.session.member.id)

  ui.container{
    attr = { class = "actions" },
    content = function()
      if not initiative.issue.fully_frozen and not initiative.issue.closed then
        if supporter then
          if not supporter:has_critical_opinion() then
            ui.container{
              attr = {
                class = "head head_supporter",
                style = "cursor: pointer;",
                onclick = "document.getElementById('support_content').style.display = 'block';"
              },
              content = function()
                ui.image{
                  static = "icons/16/thumb_up_green.png"
                }
                slot.put(_"Your are supporter")
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
                onclick = "document.getElementById('support_content').style.display = 'block';"
              },
              content = function()
                ui.image{
                  static = "icons/16/thumb_up.png"
                }
                slot.put(_"Your are potential supporter")
                ui.image{
                  static = "icons/16/dropdown.png"
                }
              end
            }
          end
          ui.container{
            attr = { class = "content", id = "support_content" },
            content = function()
              ui.container{
                attr = {
                  class = "close",
                  style = "cursor: pointer;",
                  onclick = "document.getElementById('support_content').style.display = 'none';"
                },
                content = function()
                  ui.image{ static = "icons/16/cross.png" }
                end
              }
              if supporter then
                ui.link{
                  content = function()
                    ui.image{ static = "icons/16/thumb_down_red.png" }
                    slot.put(_"Remove my support from this initiative")
                  end,
                  module = "initiative",
                  action = "remove_support",
                  id = initiative.id,
                  routing = {
                    default = {
                      mode = "redirect",
                      module = request.get_module(),
                      view = request.get_view(),
                      id = param.get_id_cgi(),
                      params = param.get_all_cgi()
                    }
                  }
                }
              else
              end
            end
          }
        else
          ui.link{
            content = function()
              ui.image{ static = "icons/16/thumb_up_green.png" }
              slot.put(_"Support this initiative")
            end,
            module = "initiative",
            action = "add_support",
            id = initiative.id,
            routing = {
              default = {
                mode = "redirect",
                module = request.get_module(),
                view = request.get_view(),
                id = param.get_id_cgi(),
                params = param.get_all_cgi()
              }
            }
          }
        end
      end
    end
  }
end)

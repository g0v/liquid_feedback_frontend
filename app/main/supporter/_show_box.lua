local initiative = param.get("initiative", "table") or Initiative:by_id(param.get_id())

-- TODO performance
local initiator = Initiator:by_pk(initiative.id, app.session.member.id)

ui.partial{
  module = "initiative",
  view = "show_support",
  id = initiative.id,
  target = "initiative_" .. tostring(initiative.id) .. "_support",
  content = function()

    ui.container{
      attr = { class = "actions" },
      content = function()

        local initiative = param.get("initiative", "table")
        local supporter = Supporter:by_pk(initiative.id, app.session.member.id)

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
              ui.container{ attr = { class = "supporter" }, content = function()
                ui.image{
                  static = "icons/16/thumb_up_green.png"
                }
                slot.put(_"Your are supporter")
              end }
            else
              ui.tag{ attr = { class = "potential_supporter" }, content = function()
                ui.image{
                  static = "icons/16/thumb_up.png"
                }
                slot.put(_"Your are potential supporter")
              end }
            end
            ui.link{
              image   = { static = "icons/16/cross.png" },
              text    = _"Withdraw support",
              module  = "initiative",
              action  = "remove_support",
              id      = initiative.id,
              routing = routing,
              partial = partial
            }
          elseif not initiative.revoked and app.session.member:has_voting_right_for_unit_id(initiative.issue.area.unit_id) then
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


        if (initiative.discussion_url and #initiative.discussion_url > 0) then
          if initiative.discussion_url:find("^https?://") then
            if initiative.discussion_url and #initiative.discussion_url > 0 then
              ui.link{
                attr = {
                  target = "_blank",
                  title = _"Discussion with initiators"
                },
                image = { static = "icons/16/comments.png" },
                text = _"Discuss with initiators",
                external = initiative.discussion_url
              }
            end
          else
            slot.put(encode.html(initiative.discussion_url))
          end
        end
        if initiator and initiator.accepted and not initiative.issue.half_frozen and not initiative.issue.closed and not initiative.revoked then
          ui.link{
            image = { static = "icons/16/comments.png" },
            text   = _"change discussion URL",
            module = "initiative",
            view   = "edit",
            id     = initiative.id
          }
        end
        if initiator and initiator.accepted and not initiative.issue.half_frozen and not initiative.issue.closed and not initiative.revoked then
          ui.link{
            content = function()
              ui.image{ static = "icons/16/script_add.png" }
              slot.put(_"Edit draft")
            end,
            module = "draft",
            view = "new",
            params = { initiative_id = initiative.id }
          }
        end

        if initiator and initiator.accepted and not initiative.issue.half_frozen and not initiative.issue.closed and not initiative.revoked then
          ui.link{
            content = function()
              ui.image{ static = "icons/16/script_delete.png" }
              slot.put(_"Revoke initiative")
            end,
            module = "initiative",
            view = "revoke",
            id = initiative.id
          }
        end
        
        if not initiative.issue.closed then
          local ignored_initiative = IgnoredInitiative:by_pk(app.session.member.id, initiative.id)
          if ignored_initiative then
            ui.container{
              attr = { class = "interest" },
              content = _"You have ignored this initiative"
            }
            ui.link{
              text   = _"Stop ignoring initiative",
              module = "initiative",
              action = "update_ignore",
              id     = initiative.id,
              params = { delete = true },
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
            ui.link{
              attr = { class = "interest" },
              text    = _"Ignore initiative",
              module  = "initiative",
              action  = "update_ignore",
              id      = initiative.id,
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

    
    slot.put("<div style='clear: left;'></div>")
  end
}

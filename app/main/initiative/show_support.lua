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
      attr = {
        class = "slot_support vote_info",
      },
      content = function()
        ui.container{
          attr = { class = "actions" },
          content = function()
            execute.view{
              module = "supporter",
              view = "_show_box",
              params = { initiative = initiative }
            }
            if initiator and initiator.accepted and not initiative.issue.half_frozen and not initiative.issue.closed and not initiative.revoked then
              ui.link{
                attr = { class = "action", style = "float: left;" },
                content = function()
                  ui.image{ static = "icons/16/script_delete.png" }
                  slot.put(_"Revoke initiative")
                end,
                module = "initiative",
                view = "revoke",
                id = initiative.id
              }
            end
          end
        }
      end
    }
    slot.put("<div style='clear: left;'></div>")
  end
}

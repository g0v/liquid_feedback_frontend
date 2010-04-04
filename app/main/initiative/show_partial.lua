local initiative = param.get("initiative", "table")
local expanded = param.get("expanded", atom.boolean)

if not initiative then
  initiative = Initiative:by_id(param.get_id())
  expanded = true
end

-- TODO performance
local initiator
if app.session.member_id then
  initiator = Initiator:by_pk(initiative.id, app.session.member.id)
end

ui.partial{
  module = "initiative",
  view = "show",
  id = initiative.id,
  target = "initiative_content_" .. tostring(initiative.id) .. "_content",
  content = function()
    if expanded then
      execute.view{
        module = "initiative",
        view = "_show",
        params = {
          initiative = initiative,
          initiator = initiator
        }
      }
    else
      slot.put("&nbsp;")
    end
  end
}

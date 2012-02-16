local initiative = param.get("initiative", "table")

if app.session.member_id
  and not initiative.issue.half_frozen
  and not initiative.issue.closed
  and not initiative.revoked
  and app.session.member:has_voting_right_for_unit_id(initiative.issue.area.unit_id)
then
  ui.link{
    content = function()
      ui.image{ static = "icons/16/comment_add.png" }
      slot.put(_"Add new suggestion")
    end,
    module = "suggestion",
    view = "new",
    params = {
      initiative_id = initiative.id
    }
  }
end

execute.view{
  module = "suggestion",
  view = "_list",
  params = {
    initiative = initiative,
    suggestions_selector = initiative:get_reference_selector("suggestions"),
    tab_id = param.get("tab_id")
  }
}


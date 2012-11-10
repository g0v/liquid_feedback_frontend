local initiative = Initiative:by_id(param.get("initiative_id", atom.integer))
local issue = initiative.issue
local member = Member:by_id(param.get("member_id", atom.integer))

local members_selector = Member:new_selector()
  :join("delegating_voter", nil, "delegating_voter.member_id = member.id")
  :add_where{ "delegating_voter.issue_id = ?", issue.id }
  :add_where{ "delegating_voter.delegate_member_id = ?", member.id }
  :join("issue", nil, "issue.id = delegating_voter.issue_id")

if member.id == app.session.member.id then
  -- show own delegation
  ui_title = ""
else
  -- show other member's delegation
  ui_title = _("Member '#{member}'", { member =  member.name }) .. ": "
end
ui.title( ui_title .. _("Incoming delegations for Issue ##{number} in Area '#{area_name}' in Unit '#{unit_name}'", { number = issue.id, area_name = issue.area.name, unit_name = issue.area.unit.name } ) )

execute.view{
  module = "member",
  view = "_list",
  params = {
    members_selector = members_selector,
    initiative = initiative,
    trustee = member,
    for_votes = true
  }
}
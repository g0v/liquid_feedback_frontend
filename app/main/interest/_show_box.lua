
local issue = param.get("issue", "table")
local initiative = param.get("initiative", "table")

local interest = Interest:by_pk(issue.id, app.session.member.id)
local membership = Membership:by_pk(issue.area_id, app.session.member_id)

if interest then

  ui.tag{ content = _"Your are interested" }
  slot.put(" ")

  if issue.state ~= "finished" and issue.state ~= "cancelled" and issue.state ~= "voting" then
    slot.put("(")
    ui.link{
      text    = _"Withdraw",
      module  = "interest",
      action  = "update",
      params  = { issue_id = issue.id, delete = true },
      routing = { default = { mode = "redirect", module = initiative and "initiative" or "issue", view = "show", id = initiative and initiative.id or issue.id } }
    }
    slot.put(") ")
  end
elseif app.session.member:has_voting_right_for_unit_id(issue.area.unit_id) then
  if not issue.closed and not issue.fully_frozen then
    ui.link{
      text    = _"Add my interest",
      module  = "interest",
      action  = "update",
      params  = { issue_id = issue.id },
      routing = { default = { mode = "redirect", module = initiative and "initiative" or "issue", view = "show", id = initiative and initiative.id or issue.id } }
    }
    slot.put(" ")
  end
end

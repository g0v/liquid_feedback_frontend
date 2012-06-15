
local issue = param.get("issue", "table")
local initiative = param.get("initiative", "table")

if issue.member_info.own_participation then

  if issue.closed then
    ui.tag{ content = _"You were interested" }
  else
    ui.tag{ content = _"You are interested" }
  end
  slot.put(" ")

  if issue.state ~= "finished" and issue.state ~= "cancelled" and issue.state ~= "voting" then
    slot.put("(")
    ui.link{
      text    = _"Withdraw",
      module  = "interest",
      action  = "update",
      params  = { issue_id = issue.id, delete = true },
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
    slot.put(") ")
  end
elseif app.session.member:has_voting_right_for_unit_id(issue.area.unit_id) then
  if not issue.closed and not issue.fully_frozen then
    ui.link{
      text    = _"Add my interest",
      module  = "interest",
      action  = "update",
      params  = { issue_id = issue.id },
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
    slot.put(" ")
  end
end

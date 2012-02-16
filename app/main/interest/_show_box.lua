
local issue = param.get("issue", "table")

local interest = Interest:by_pk(issue.id, app.session.member.id)
local membership = Membership:by_pk(issue.area_id, app.session.member_id)

slot.select("interest", function()
  if interest then

  ui.container{
    content = function()
        ui.container{
          attr = { 
            class = "head head_active",
          },
          content = function()
            ui.image{
              static = "icons/16/eye.png"
            }
            slot.put(_"Your are interested")

          end
        }

        if issue.state ~= "finished" and issue.state ~= "cancelled" and issue.state ~= "voting" then
          ui.link{
            image   = { static = "icons/16/cross.png" },
            text    = _"Withdraw interest",
            module  = "interest",
            action  = "update",
            params  = { issue_id = issue.id, delete = true },
            routing = { default = { mode = "redirect", module = "issue", view = "show", id = issue.id } }
          }
        end
      end
    }
  elseif app.session.member:has_voting_right_for_unit_id(issue.area.unit_id) then
    if not issue.closed and not issue.fully_frozen then
      ui.link{
        image   = { static = "icons/16/user_add.png" },
        text    = _"Add my interest",
        module  = "interest",
        action  = "update",
        params  = { issue_id = issue.id },
        routing = { default = { mode = "redirect", module = "issue", view = "show", id = issue.id } }
      }
    end
  end
end)

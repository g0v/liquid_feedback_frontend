
local issue = param.get("issue", "table")

local interest = Interest:by_pk(issue.id, app.session.member.id)
local membership = Membership:by_pk(issue.area_id, app.session.member_id)

if interest then
  slot.select("actions", function()

  ui.container{
    attr = { class = "interest vote_info"},
    content = function()
        ui.container{
          attr = { 
            class = "head head_active",
            onclick = "document.getElementById('interest_content').style.display = 'block';"
          },
          content = function()
            ui.image{
              static = "icons/16/eye.png"
            }
            slot.put(_"Your are interested")

            ui.image{
              static = "icons/16/dropdown.png"
            }
          end
        }
    
        ui.container{
          attr = { class = "content", id = "interest_content" },
          content = function()
            ui.container{
              attr = {
                class = "close",
                style = "cursor: pointer;",
                onclick = "document.getElementById('interest_content').style.display = 'none';"
              },
              content = function()
                ui.image{ static = "icons/16/cross.png" }
              end
            }
            if issue.state ~= "finished" and issue.state ~= "cancelled" and issue.state ~= "voting" then
              ui.link{
                text    = _"Remove my interest",
                module  = "interest",
                action  = "update",
                params  = { issue_id = issue.id, delete = true },
                routing = { default = { mode = "redirect", module = "issue", view = "show", id = issue.id } }
              }
              slot.put("<br />")
              slot.put("<br />")
            end
          end
        }
      end
    }
  end)
else
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

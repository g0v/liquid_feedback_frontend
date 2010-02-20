local issue = param.get("issue", "table")


if issue.closed and issue.half_frozen then
  return
end

local interest = Interest:by_pk(issue.id, app.session.member.id)

if not interest then
  return
end

if interest.voting_requested ~= nil then
  slot.select("actions", function()

  ui.container{
    attr = { class = "voting_requested vote_info"},
    content = function()
        ui.container{
          attr = { 
            class = "head head_active",
            onclick = "document.getElementById('voting_requested_content').style.display = 'block';"
          },
          content = function()
            if interest.voting_requested == false then
              ui.image{
                static = "icons/16/clock_play.png"
              }
              slot.put(_"You want to vote later")
              ui.image{
                static = "icons/16/dropdown.png"
              }
            end
          end
        }
        ui.container{
          attr = { class = "content", id = "voting_requested_content" },
          content = function()
            ui.container{
              attr = {
                class = "close",
                style = "cursor: pointer;",
                onclick = "document.getElementById('voting_requested_content').style.display = 'none';"
              },
              content = function()
                ui.image{ static = "icons/16/cross.png" }
              end
            }
            ui.link{
              text    = _"Remove my request to vote later",
              module  = "interest",
              action  = "update_voting_requested",
              params  = { issue_id = issue.id, voting_requested = nil },
              routing = { default = { mode = "redirect", module = "issue", view = "show", id = issue.id } }
            }
            slot.put("<br />")
          end
        }
      end
    }
  end)
else
  if not issue.closed and not issue.half_frozen then
    ui.link{
      image  = { static = "icons/16/clock_play.png" },
      text   = _"Vote later",
      module = "interest",
      action = "update_voting_requested",
      params = {
        issue_id = issue.id,
        voting_requested = false
      },
      routing = { default = { mode = "redirect", module = "issue", view = "show", id = issue.id } }
    }
  end
end
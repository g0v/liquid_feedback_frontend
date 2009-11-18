
local issue = param.get("issue", "table")


slot.select("interest", function()
  local interest = Interest:by_pk(issue.id, app.session.member.id)

  ui.container{
    attr = { 
      class = "head",
      onclick = "document.getElementById('interest_content').style.display = 'block';"
    },
    content = function()
      if interest then
        ui.field.text{ value = _"You are interested. [more]" }
      else
        ui.field.text{ value = _"You are not interested. [more]" }
      end
    end
  }

  ui.container{
    attr = { class = "content", id = "interest_content" },
    content = function()
      if interest then
        ui.link{
          content = _"Remove my interest",
          module = "interest",
          action = "update",
          params = { issue_id = issue.id, delete = true },
          routing = { default = { mode = "redirect", module = "issue", view = "show", id = issue.id } }
        }
        if interest.autoreject then
          ui.field.text{ value = _"Autoreject is on." }
          ui.link{
            content = _"Remove autoreject",
            module = "interest",
            action = "update",
            params = { issue_id = issue.id, autoreject = false },
            routing = { default = { mode = "redirect", module = "issue", view = "show", id = issue.id } }
          }
        else
          ui.field.text{ value = _"Autoreject is off." }
          ui.link{
            content = _"Set autoreject",
            module = "interest",
            action = "update",
            params = { issue_id = issue.id, autoreject = true },
            routing = { default = { mode = "redirect", module = "issue", view = "show", id = issue.id } }
          }
        end
      else
        ui.link{
          content = _"Add my interest to this issue",
          module = "interest",
          action = "update",
          params = { issue_id = issue.id },
          routing = { default = { mode = "redirect", module = "issue", view = "show", id = issue.id } }
        }
      end
        ui.container{
          attr = {
            class = "head",
            style = "cursor: pointer;",
            onclick = "document.getElementById('interest_content').style.display = 'none';"
          },
          content = _"Click here to close."
        }
    end
  }
end)

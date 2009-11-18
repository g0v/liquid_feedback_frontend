    

slot.select("support", function()

  local initiative = param.get("initiative", "table")

  if not initiative.issue.frozen and not initiative.issue.closed then

    local supported = Supporter:by_pk(initiative.id, app.session.member.id) and true or false

    local text
    if supported then
      text = _"Direct supporter [change]"
    else
      text = _"No supporter [change]"
    end
    ui.container{
      attr = {
        class = "head",
        style = "cursor: pointer;",
        onclick = "document.getElementById('support_content').style.display = 'block';"
      },
      content = text
    }


    ui.container{
      attr = { class = "content", id = "support_content" },
      content = function()
        if supported then
          ui.link{
            content = function()
              ui.image{ static = "icons/16/thumb_down_red.png" }
              slot.put(_"Remove my support from this initiative")
            end,
            module = "initiative",
            action = "remove_support",
            id = initiative.id
          }
        else
          ui.link{
            content = function()
              ui.image{ static = "icons/16/thumb_up_green.png" }
              slot.put(_"Support this initiative")
            end,
            module = "initiative",
            action = "add_support",
            id = initiative.id
          }
        end
      end
    }
  end

end)

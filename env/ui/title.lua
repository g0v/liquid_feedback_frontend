function ui.title(content, unit, area, issue, initiative)
  slot.select("head", function()

    if unit then
      ui.container{ attr = { class = "path" }, content = function()
        ui.link{
          module = "unit",
          view = "show",
          id = unit_id,
          attr = { class = "unit_link" },
          text = unit.name
        }
        if area then
          ui.link{
            module = "area",
            view = "show",
            id = area_id,
            attr = { class = "area_link" },
            text = area.name
          }
          if issue then
            ui.link{
              module = "issue",
              view = "show",
              id = issue.id,
              attr = { class = "issue_link" },
              text = issue.policy.name .. " #" .. issue.id
            }
            if initiative then
              -- limit length of initiative name
              local name = initiative.name
              if #name > 50 then
                name = name:sub(1,48) .. "..."
              end
              ui.link{
                module = "initiative",
                view = "show",
                id = initiative.id,
                attr = { class = "ini_link" },
                text = _("i#{id}: #{name}", { id = initiative.id, name = name })
              }
            end
          end
        end
      end }
      ui.container{ attr = { class = "title left" }, content = content }
      slot.put('<div class="clearfix"></div>')
    else
      ui.container{ attr = { class = "title" }, content = content }
    end

  end)
end
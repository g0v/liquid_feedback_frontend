local issue = param.get("issue", "table")

slot.select("issue_info", function()
  ui.tag{
    tag = "div",
    content = function()
      ui.tag{
        tag = "label",
        attr = { class = "ui_field_label" },
        content = _"Policy",
      }
      ui.tag{
        content = function()
          ui.link{
            text = issue.policy.name,
            module = "policy",
            view = "show",
            id = issue.policy.id
          }
        end
      }

    end
  }

  ui.field.text{ 
    label = _"State",
    value = issue.state_name 
  }
  local time_left = issue.state_time_left
  if time_left then
    ui.field.text{ 
      label = _"Time left",
      value = time_left
    }
  end
  local next_state_names = issue.next_states_names
  if next_state_names then
    ui.field.text{ 
      label = _"Next state",
      value = next_state_names
    }
  end
end)

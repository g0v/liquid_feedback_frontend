ui.title(_"Policies")

util.help("policy.list", _"Policies")
local policies = Policy:new_selector()
  :add_where("active")
  :add_order_by("index")
  :exec()

ui.list{
  records = policies,
  columns = {
    {
      label_attr = { width = "500" },
      label = _"Policy",
      content = function(policy)
        ui.tag{
          tag = "div",
          attr = { style = "font-weight: bold" },
          content = function()
            slot.put(encode.html(policy.name))
            if not policy.active then
              slot.put(" (", _"disabled", ")")
            end
          end
        }
        ui.tag{
          tag = "div",
          content = policy.description
        }
      end
    },
    {
      label_attr = { width = "200" },
      label = _"Phases",
      content = function(policy)
        ui.field.text{ label = _"New" .. ":", value = "≤ " .. policy.admission_time }
        ui.field.text{ label = _"Discussion" .. ":", value = policy.discussion_time }
        ui.field.text{ label = _"Frozen" .. ":", value = policy.verification_time }
        ui.field.text{ label = _"Voting" .. ":", value = policy.voting_time }
      end
    },
    {
      label_attr = { width = "200" },
      label = _"Quorum",
      content = function(policy)
        ui.field.text{
          label = _"Issue quorum" .. ":", 
          value = "≥ " .. tostring(policy.issue_quorum_num) .. "/" .. tostring(policy.issue_quorum_den)
        }
        ui.field.text{
          label = _"Initiative quorum" .. ":", 
          value = "≥ " .. tostring(policy.initiative_quorum_num) .. "/" .. tostring(policy.initiative_quorum_den)
        }
        ui.field.text{
          label = _"majority" .. ":", 
          value = (policy.direct_majority_strict and ">" or "≥" ) .. " " .. tostring(policy.direct_majority_num) .. "/" .. tostring(policy.direct_majority_den)
        }
      end
    },
  }
}
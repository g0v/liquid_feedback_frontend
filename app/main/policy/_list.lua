local admin = param.get("admin", atom.boolean)
local policies = param.get("policies", "table")
local show_not_in_use = param.get("show_not_in_use", atom.boolean)

local i = 0;
local columns = {}

if admin and not show_not_in_use then
  columns[#columns+1] = {
    content = function(policy)

      i = i + 1

      if i ~= 1 then
        ui.link{
          attr = { alt = _"up", title = _"up" },
          module = "admin",
          action = "policy_order_update",
          routing = {
            default = {
              mode = "redirect",
              module = "admin",
              view = "policy_list"
            }
          },
          params = {
            policy_id = policy.id,
            policy_swap_id = policies[i-1].id
          },
          content = function()
            slot.put("&uarr;")
          end
        }
      end

      if i ~= #policies then
        ui.link{
          attr = { alt = _"down", title = _"down" },
          module = "admin",
          action = "policy_order_update",
          routing = {
            default = {
              mode = "redirect",
              module = "admin",
              view = "policy_list"
            }
          },
          params = {
            policy_id = policy.id,
            policy_swap_id = policies[i+1].id
          },
          content = function()
            slot.put("&darr;")
          end
        }
      end

    end
  }
end

columns[#columns+1] = {
  label_attr = { width = "60%" },
  label = _"Policy",
  content = function(policy)
    ui.link{
      module = "policy", view = "show", id = policy.id,
      attr = { style = "font-weight: bold" },
      content = function()
        slot.put(encode.html(policy.name))
        if not policy.active then
          slot.put(" (", _"disabled", ")")
        end
      end
    }
    if admin then
      slot.put(" &middot; ")
      ui.link{
        text = _"Edit",
        module = "admin",
        view = "policy_show",
        id = policy.id
      }
    end
    ui.tag{
      tag = "div",
      content = policy.description
    }
  end
}

columns[#columns+1] = {
  label_attr = { width = "20%" },
  label = _"Phases",
  content = function(policy)
    if policy.polling then
      ui.field.text{ label = _"New" .. ":", value = _"without" }
    else
      ui.field.text{ label = _"New" .. ":", value = "≤ " .. format.interval_text(policy.admission_time) }
    end
    ui.field.text{
      label = _"Discussion" .. ":",
      value = policy.discussion_time   and format.interval_text(policy.discussion_time)   or _"variable"
    }
    ui.field.text{
      label = _"Frozen" .. ":",
      value = policy.verification_time and format.interval_text(policy.verification_time) or _"variable"
    }
    ui.field.text{
      label = _"Voting" .. ":",
      value = policy.voting_time       and format.interval_text(policy.voting_time)       or _"variable"
    }
  end
}

columns[#columns+1] = {
  label_attr = { width = "20%" },
  label = _"Quorum",
  content = function(policy)
    if policy.polling then
      ui.field.text{ label = _"Issue quorum" .. ":", value = _"without" }
    else
      if policy.issue_quorum_num then
        ui.field.text{
          label = _"Issue quorum" .. ":",
          value = "≥ " .. tostring(policy.issue_quorum_num) .. "/" .. tostring(policy.issue_quorum_den)
        }
      end
      if policy.issue_quorum_direct_num then
        ui.field.text{
          label = _"Issue direct quorum" .. ":",
          value = "≥ " .. tostring(policy.issue_quorum_direct_num) .. "/" .. tostring(policy.issue_quorum_direct_den)
        }
      end
    end
    ui.field.text{
      label = _"Initiative quorum" .. ":",
      value = "≥ " .. tostring(policy.initiative_quorum_num) .. "/" .. tostring(policy.initiative_quorum_den)
    }
    ui.field.text{
      label = _"Direct majority" .. ":",
      value = (policy.direct_majority_strict and ">" or "≥" ) .. " " .. tostring(policy.direct_majority_num) .. "/" .. tostring(policy.direct_majority_den)
    }
    ui.field.text{
      label = _"Indirect majority" .. ":",
      value = (policy.indirect_majority_strict and ">" or "≥" ) .. " " .. tostring(policy.indirect_majority_num) .. "/" .. tostring(policy.indirect_majority_den)
    }
    if not policy.delegation then
      ui.field.text{
        label = _"Delegation" .. ":",
        value = "off"
      }
    end
  end
}

ui.list{
  records = policies,
  columns = columns
}

local policy      = Policy:by_id(param.get("policy_id"))
local policy_swap = Policy:by_id(param.get("policy_swap_id"))

if policy_swap.index == policy.index then
  -- renumber
  local policies = Policy:build_selector{}:exec()
  for i, value in ipairs(policies) do
    value.index = i
    value:save()
  end
  policy      = Policy:by_id(param.get("policy_id"))
  policy_swap = Policy:by_id(param.get("policy_swap_id"))
end

-- flip indexes
local temp_index = policy_swap.index
policy_swap.index = policy.index
policy.index = temp_index

policy:save()
policy_swap:save()

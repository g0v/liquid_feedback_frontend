Area = mondelefant.new_class()
Area.table = 'area'

Area:add_reference{
  mode          = 'm1',
  to            = "Unit",
  this_key      = 'unit_id',
  that_key      = 'id',
  ref           = 'unit',
}

Area:add_reference{
  mode          = '1m',
  to            = "Issue",
  this_key      = 'id',
  that_key      = 'area_id',
  ref           = 'issues',
  back_ref      = 'area'
}

Area:add_reference{
  mode          = '1m',
  to            = "Membership",
  this_key      = 'id',
  that_key      = 'area_id',
  ref           = 'memberships',
  back_ref      = 'area'
}

Area:add_reference{
  mode          = '1m',
  to            = "Delegation",
  this_key      = 'id',
  that_key      = 'area_id',
  ref           = 'delegations',
  back_ref      = 'area'
}

Area:add_reference{
  mode                  = 'mm',
  to                    = "Member",
  this_key              = 'id',
  that_key              = 'id',
  connected_by_table    = 'membership',
  connected_by_this_key = 'area_id',
  connected_by_that_key = 'member_id',
  ref                   = 'members'
}

Area:add_reference{
  mode                  = 'mm',
  to                    = "Policy",
  this_key              = 'id',
  that_key              = 'id',
  connected_by_table    = 'allowed_policy',
  connected_by_this_key = 'area_id',
  connected_by_that_key = 'policy_id',
  ref                   = 'allowed_policies'
}

function Area.object_get:default_policy()
  return Policy:new_selector()
    :join("allowed_policy", nil, "allowed_policy.policy_id = policy.id")
    :add_where{ "allowed_policy.area_id = ? AND allowed_policy.default_policy", self.id }
    :optional_object_mode()
    :exec()
end

function Area:build_selector(args)
  local selector = Area:new_selector()
  if args.active ~= nil then
    selector:add_where{ "area.active = ?", args.active }
  end
  if args.unit_id ~= nil then
    selector:add_where{ "area.unit_id = ?", args.unit_id }
  end
  return selector
end

function Area.object_get:name_with_unit_name()
  if not config.single_unit_id then
    return self.unit.name .. ", " .. self.name
  else
    return self.name
  end
end
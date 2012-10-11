Policy = mondelefant.new_class()
Policy.table = 'policy'

Policy:add_reference{
  mode          = '1m',
  to            = "Issue",
  this_key      = 'id',
  that_key      = 'policy_id',
  ref           = 'issues',
  back_ref      = 'policy'
}

function Policy:build_selector(args)
  local selector = self:new_selector()
  if args.active ~= nil then
    selector:add_where{ "active = ?", args.active }
  end
  selector:add_order_by("index")
  return selector
end

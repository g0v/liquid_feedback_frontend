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

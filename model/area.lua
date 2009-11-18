Area = mondelefant.new_class()
Area.table = 'area'

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
  mode                  = 'mm',
  to                    = "Member",
  this_key              = 'id',
  that_key              = 'id',
  connected_by_table    = 'membership',
  connected_by_this_key = 'area_id',
  connected_by_that_key = 'member_id',
  ref                   = 'members'
}

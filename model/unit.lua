Unit = mondelefant.new_class()
Unit.table = 'unit'

Unit:add_reference{
  mode          = '1m',
  to            = "Area",
  this_key      = 'id',
  that_key      = 'unit_id',
  ref           = 'areas',
  back_ref      = 'unit'
}

Unit:add_reference{
  mode                  = 'mm',
  to                    = "Member",
  this_key              = 'id',
  that_key              = 'id',
  connected_by_table    = 'privilege',
  connected_by_this_key = 'unit_id',
  connected_by_that_key = 'member_id',
  ref                   = 'members'
}

function Unit:get_flattened_tree()
  -- TODO implement

  return Unit:new_selector():exec()
end

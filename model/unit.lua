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

function Unit:get_flattened_tree()
  -- TODO implement

  return Unit:new_selector():exec()
end

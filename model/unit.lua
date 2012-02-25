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

function recursive_add_child_units(units, parent_unit)
  parent_unit.childs = {}
  for i, unit in ipairs(units) do
    if unit.parent_id == parent_unit.id then
      parent_unit.childs[#(parent_unit.childs)+1] = unit
      recursive_add_child_units(units, unit)
    end
  end
end  

function recursive_get_child_units(units, parent_unit, depth)
  for i, unit in ipairs(parent_unit.childs) do
    unit.depth = depth
    units[#units+1] = unit
    recursive_get_child_units(units, unit, depth + 1)
  end
end

function Unit:get_flattened_tree()
  local units = Unit:new_selector():add_order_by("name"):exec()
  local unit_tree = {}
  for i, unit in ipairs(units) do
    if not unit.parent_id then
      unit_tree[#unit_tree+1] = unit
      recursive_add_child_units(units, unit)
    end
  end
  local depth = 1
  local units = {}
  for i, unit in ipairs(unit_tree) do
    unit.depth = depth
    units[#units+1] = unit
    recursive_get_child_units(units, unit, depth + 1)
  end
  return units
end

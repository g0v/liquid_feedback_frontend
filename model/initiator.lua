Initiator = mondelefant.new_class()
Initiator.table = 'initiator'
Initiator.primary_key = { "initiative_id", "member_id" }

Initiator:add_reference{
  mode          = 'm1',
  to            = "Initiative",
  this_key      = 'initiative_id',
  that_key      = 'id',
  ref           = 'initiative',
}

Initiator:add_reference{
  mode          = 'm1',
  to            = "Member",
  this_key      = 'member_id',
  that_key      = 'id',
  ref           = 'member',
}

function Initiator:by_pk(initiative_id, member_id)
  return self:new_selector()
    :add_where{ "initiative_id = ?", initiative_id }
    :add_where{ "member_id = ?", member_id }
    :optional_object_mode()
    :exec()
end

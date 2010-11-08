Contact = mondelefant.new_class()
Contact.table = 'contact'
Contact.primary_key = { "member_id", "other_member_id" }

Contact:add_reference{
  mode          = 'm1',
  to            = "Member",
  this_key      = 'member_id',
  that_key      = 'id',
  ref           = 'member',
}

Contact:add_reference{
  mode          = 'm1',
  to            = "Member",
  this_key      = 'other_member_id',
  that_key      = 'id',
  ref           = 'other_member',
}


function Contact:by_pk(member_id, other_member_id)
  return self:new_selector()
    :add_where{ "member_id = ?", member_id }
    :add_where{ "other_member_id = ?", other_member_id }
    :optional_object_mode()
    :exec()
end

function Contact:build_selector(args)
  local selector = Contact:new_selector()
  if args.member_id then
    selector:add_where{ "member_id = ?", args.member_id }
  end
  if order then
    if order == "name" then
      selector:add_order_by("name")
    else
      error("invalid order")
    end
  end
  return selector
end

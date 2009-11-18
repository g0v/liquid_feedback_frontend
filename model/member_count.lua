MemberCount = mondelefant.new_class()
MemberCount.table = 'member_count'

function MemberCount:get()
  return self:new_selector():single_object_mode():exec().total_count
end
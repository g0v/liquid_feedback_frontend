local issue_id = assert(param.get("issue_id", atom.integer), "no issue id given")

local interest = Interest:by_pk(issue_id, app.session.member.id)

local issue = Issue:new_selector():add_where{ "id = ?", issue_id }:for_share():single_object_mode():exec()

if issue.closed then
  slot.put_into("error", _"This issue is already closed.")
  return false
elseif issue.half_frozen then 
  slot.put_into("error", _"This issue is already frozen.")
  return false
end

interest.voting_requested = param.get("voting_requested", atom.boolean)

if interest.voting_requested == true then
  error("not implemented yet")
end

interest:save()

slot.put_into("notice", _"Voting request updated")

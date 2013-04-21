local trustee_id = param.get("trustee_id", atom.integer)
local unit_id = param.get("unit_id", atom.integer)
local area_id = param.get("area_id", atom.integer)
local issue_id = param.get("issue_id", atom.integer)
local initiative_id = param.get("initiative_id", atom.integer)

if issue_id then
  area_id = nil
end

-- ignore empty submitted form
if trustee_id == "_" then
  return
end

local delegation = Delegation:by_trustee(app.session.member.id, trustee_id, unit_id, area_id, issue_id)

if param.get("delete") then

  if delegation then
    delegation:destroy()
  end

elseif param.get("continue") then

  delegation.confirmed = 'now'
  delegation.active = true
  delegation:save()

elseif param.get("trustee_swap_id") then

  local delegation_swap = Delegation:by_trustee(app.session.member.id, param.get("trustee_swap_id"), unit_id, area_id, issue_id)

  -- get preference ranks
  local delegation_preference = delegation.preference
  local delegation_swap_preference = delegation_swap.preference
  -- save dummy rank to satisfy UNIQUE constraint
  delegation.preference = -1
  delegation:save()
  -- save actual preference ranks
  delegation_swap.preference = delegation_preference
  delegation_swap:save()
  delegation.preference = delegation_swap_preference
  delegation:save()

else

  -- add delegation

  -- ignore if this trustee is already in the list
  if delegation then
    return
  end

  -- get unit id for checks
  local check_unit_id
  if unit_id then
    check_unit_id = unit_id
  elseif area_id then
    local area = Area:by_id(area_id)
    check_unit_id = area.unit_id
  else
    local issue = Issue:by_id(issue_id)
    local area = Area:by_id(issue.area_id)
    check_unit_id = area.unit_id
  end

  -- check if delegating member has voting right
  if not app.session.member:has_voting_right_for_unit_id(check_unit_id) then
    slot.put_into("error", _"You have no voting right in this unit!")
  end

  -- check if trustee has voting right
  local trustee = Member:by_id(trustee_id)
  if not trustee:has_voting_right_for_unit_id(check_unit_id) then
    slot.put_into("error", _"Trustee has no voting right in this unit!")
    return false
  end

  -- check for maximum number of delegations to avoid performance problems
  if Delegation:count(app.session.member.id, unit_id, area_id, issue_id) >= 100 then
    slot.put_into("error", _"The maximum number of delegations for one preference list is reached!")
    return false
  end

  -- create new delegation
  delegation = Delegation:new()
  delegation.truster_id = app.session.member.id
  delegation.unit_id    = unit_id
  delegation.area_id    = area_id
  delegation.issue_id   = issue_id
  if issue_id then
    delegation.scope = "issue"
  elseif area_id then
    delegation.scope = "area"
  elseif unit_id then
    delegation.scope = "unit"
  end
  delegation.trustee_id = trustee_id

  delegation:save()

end

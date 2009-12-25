local truster_id = app.session.member.id

local trustee_id = param.get("trustee_id", atom.integer)

local area_id = param.get("area_id", atom.integer)

local issue_id = param.get("issue_id", atom.integer)

if issue_id then 
  area_id = nil
end

local delegation = Delegation:by_pk(truster_id, area_id, issue_id)

if param.get("delete") or trustee_id == -1 then

  if delegation then

    delegation:destroy()

    if issue_id then
      slot.put_into("notice", _"Your delegation for this issue has been deleted.")
    elseif area_id then
      slot.put_into("notice", _"Your delegation for this area has been deleted.")
    else
      slot.put_into("notice", _"Your global delegation has been deleted.")
    end

  end

else

  if not delegation then
    delegation = Delegation:new()
    delegation.truster_id = truster_id
    delegation.area_id    = area_id
    delegation.issue_id   = issue_id
    if issue_id then
      delegation.scope = "issue"
    elseif area_id then
      delegation.scope = "area"
    else
      delegation.scope = "global"
    end
  end

  delegation.trustee_id = trustee_id

  delegation:save()

  if issue_id then
    slot.put_into("notice", _"Your delegation for this issue has been updated.")
  elseif area_id then
    slot.put_into("notice", _"Your delegation for this area has been updated.")
  else
    slot.put_into("notice", _"Your global delegation has been updated.")
  end

end


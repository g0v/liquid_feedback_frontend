local initiative = Initiative:new_selector():add_where{ "id = ?", param.get_id()}:single_object_mode():exec()
local auto_support = param.get("auto_support", atom.boolean)

-- TODO important m1 selectors returning result _SET_!
local issue = initiative:get_reference_selector("issue"):for_share():single_object_mode():exec()

if issue.closed then
  slot.put_into("error", _"This issue is already closed.")
  return false
elseif issue.fully_frozen then 
  slot.put_into("error", _"Voting for this issue has already begun.")
  return false
end

if initiative.revoked then
  slot.put_into("error", _"This initiative is revoked")
  return false
end

local member = app.session.member

local supporter = Supporter:by_pk(initiative.id, member.id)

local last_draft = Draft:new_selector()
  :add_where{ "initiative_id = ?", initiative.id }
  :add_order_by("id DESC")
  :limit(1)
  :single_object_mode()
  :exec()

if not supporter then
  supporter = Supporter:new()
  supporter.member_id = member.id
  supporter.initiative_id = initiative.id
  supporter.draft_id = last_draft.id
  supporter.auto_support = auto_support
  supporter:save()
  slot.put_into("notice", _"Your support has been added to this initiative")
  if supporter.auto_active then
    slot.put_into("notice", _"Auto support is now enabled")
  end
elseif (auto_support ~= nil and supporter.auto_support ~= auto_support) and config.auto_support then
  supporter.auto_support = auto_support
  if auto_support then
    slot.put_into("notice", _"Auto support is now enabled")
  else
    slot.put_into("notice", _"Auto support is now disabled")
  end
  supporter.draft_id = last_draft.id
  supporter:save()
elseif supporter.draft_id ~= last_draft.id then
  supporter.draft_id = last_draft.id
  supporter:save()
  slot.put_into("notice", _"Your support has been updated to the latest draft")
else
  slot.put_into("notice", _"You are already supporting the latest draft")
end


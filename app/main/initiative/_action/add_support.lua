local initiative = Initiative:new_selector():add_where{ "id = ?", param.get_id()}:single_object_mode():exec()

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
  supporter:save()
  slot.put_into("notice", _"Your support has been added to this initiative")
elseif supporter.draft_id ~= last_draft.id then
  supporter.draft_id = last_draft.id
  supporter:save()
  slot.put_into("notice", _"Your support has been updated to the latest draft")
else
  slot.put_into("notice", _"You are already supporting the latest draft")
end
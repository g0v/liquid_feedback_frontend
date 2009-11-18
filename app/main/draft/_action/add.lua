local initiative = Initiative:by_id(param.get("initiative_id", atom.integer))

if Initiator:by_pk(initiative.id, app.session.member.id) then
  local draft = Draft:new()
  draft.author_id = app.session.member.id
  draft.initiative_id = initiative.id
  draft.content = param.get("content")
  draft:save()

  slot.put_into("notice", _"New draft has been added to initiative")

else
  error('access denied')
end

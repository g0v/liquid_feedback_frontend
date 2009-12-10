local initiative = Initiative:by_id(param.get("initiative_id", atom.integer))

if Initiator:by_pk(initiative.id, app.session.member.id) then
  local draft = Draft:new()
  draft.author_id = app.session.member.id
  draft.initiative_id = initiative.id
  local formatting_engine = param.get("formatting_engine")
  local formatting_engine_valid = false
  for fe, dummy in pairs(config.formatting_engine_executeables) do
    if formatting_engine == fe then
      formatting_engine_valid = true
    end
  end
  if not formatting_engine_valid then
    error("invalid formatting engine!")
  end
  draft.formatting_engine = formatting_engine
  draft.content = param.get("content")
  draft:save()

  slot.put_into("notice", _"New draft has been added to initiative")

else
  error('access denied')
end

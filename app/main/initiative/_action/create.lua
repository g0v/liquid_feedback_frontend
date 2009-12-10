local issue
local area

db:query("BEGIN")

local issue_id = param.get("issue_id", atom.integer)
if issue_id then
  issue = Issue:new_selector():add_where{"id=?",issue_id}:single_object_mode():exec()
  area = issue.area

else
  local area_id = param.get("area_id", atom.integer)
  area = Area:new_selector():add_where{"id=?",area_id}:single_object_mode():exec()
end

local initiative = Initiative:new()

if not issue then
  issue = Issue:new()
  issue.area_id = area.id
  issue.policy_id = param.get("policy_id", atom.integer)
  issue:save()
end

initiative.issue_id = issue.id

param.update(initiative, "name", "discussion_url")
initiative:save()

local draft = Draft:new()
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
draft.content = param.get("draft")
draft.author_id = app.session.member.id
draft:save()

local initiator = Initiator:new()
initiator.initiative_id = initiative.id
initiator.member_id = app.session.member.id
initiator:save()

local supporter = Supporter:new()
supporter.initiative_id = initiative.id
supporter.member_id = app.session.member.id
supporter.draft_id = draft.id
supporter:save()

db:query("COMMIT")

slot.put_into("notice", _"Initiative successfully created")

request.redirect{
  module = "initiative",
  view = "show",
  id = initiative.id
}
local tmp = db:query({ "SELECT text_entries_left, initiatives_left FROM member_contingent_left WHERE member_id = ?", app.session.member.id }, "opt_object")
if tmp then
  if tmp.initiatives_left and tmp.initiatives_left < 1 then
    slot.put_into("error", _"Sorry, your contingent for creating initiatives has been used up. Please try again later.")
    return false
  end
  if tmp.text_entries_left and tmp.text_entries_left < 1 then
    slot.put_into("error", _"Sorry, you have reached your personal flood limit. Please be slower...")
    return false
  end
end

local issue
local area

local issue_id = param.get("issue_id", atom.integer)
if issue_id then
  issue = Issue:new_selector():add_where{"id=?",issue_id}:single_object_mode():exec()
  if issue.closed then
    slot.put_into("error", _"This issue is already closed.")
    return false
  elseif issue.fully_frozen then 
    slot.put_into("error", _"Voting for this issue has already begun.")
    return false
  end
  area = issue.area
else
  local area_id = param.get("area_id", atom.integer)
  area = Area:new_selector():add_where{"id=?",area_id}:single_object_mode():exec()
  if not area.active then
    slot.put_into("error", "Invalid area.")
    return false
  end
end

if not app.session.member:has_voting_right_for_unit_id(area.unit_id) then
  error("access denied")
end

local name = param.get("name")

local name = util.trim(name)

if #name < 3 then
  slot.put_into("error", _"This name is really too short!")
  return false
end

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

if param.get("preview") then
  return
end


local initiative = Initiative:new()

if not issue then
  local policy_id = param.get("policy_id", atom.integer)
  if policy_id == -1 then
    slot.put_into("error", _"Please choose a policy")
    return false
  end
  local policy = Policy:by_id(policy_id)
  if not policy.active then
    slot.put_into("error", "Invalid policy.")
    return false
  end
  if not area:get_reference_selector("allowed_policies")
    :add_where{ "policy.id = ?", policy_id }
    :optional_object_mode()
    :exec()
  then
    error("policy not allowed")
  end
  issue = Issue:new()
  issue.area_id = area.id
  issue.policy_id = policy_id
  issue:save()

  if config.etherpad then
    local result = net.curl(
      config.etherpad.api_base 
      .. "api/1/createGroupPad?apikey=" .. config.etherpad.api_key
      .. "&groupID=" .. config.etherpad.group_id
      .. "&padName=Issue" .. tostring(issue.id)
      .. "&text=" .. config.absolute_base_url .. "issue/show/" .. tostring(issue.id) .. ".html"
    )
  end
end

initiative.issue_id = issue.id
initiative.name = name
param.update(initiative, "discussion_url")
initiative:save()

local draft = Draft:new()
draft.initiative_id = initiative.id
draft.formatting_engine = formatting_engine
draft.content = param.get("draft")
draft.author_id = app.session.member.id
draft:save()

local initiator = Initiator:new()
initiator.initiative_id = initiative.id
initiator.member_id = app.session.member.id
initiator.accepted = true
initiator:save()

local supporter = Supporter:new()
supporter.initiative_id = initiative.id
supporter.member_id = app.session.member.id
supporter.draft_id = draft.id
supporter:save()

slot.put_into("notice", _"Initiative successfully created")

request.redirect{
  module = "initiative",
  view = "show",
  id = initiative.id
}
local issue = Issue:new_selector():add_where{ "id = ?", param.get("issue_id", atom.integer) }:for_share():single_object_mode():exec()

if issue.closed then
  slot.put_into("error", _"This issue is already closed.")
  return false
end

if issue.state ~= "voting" then
  slot.put_into("error", _"Voting has not started yet.")
  return false
end

local direct_voter = DirectVoter:by_pk(issue.id, app.session.member_id)

if not direct_voter then
  direct_voter = DirectVoter:new()
  direct_voter.issue_id = issue.id
  direct_voter.member_id = app.session.member_id
end

direct_voter.autoreject = false

direct_voter:save()


local scoring = param.get("scoring")

for initiative_id, grade in scoring:gmatch("([^:;]+):([^:;]+)") do
  local initiative_id = tonumber(initiative_id)
  local grade = tonumber(grade)
  local initiative = Initiative:by_id(initiative_id)
  if initiative.issue.id ~= issue.id then
    error("initiative from wrong issue")
  end
  local vote = Vote:by_pk(initiative_id, app.session.member.id)
  if not vote then
    vote = Vote:new()
    vote.issue_id = issue.id
    vote.initiative_id = initiative.id
    vote.member_id = app.session.member.id
  end
  vote.grade = grade
  vote:save()
end

trace.debug(scoring)


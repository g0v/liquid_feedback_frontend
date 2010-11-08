local policy = Policy:by_id(param.get_id()) or Policy:new()

param.update(
  policy, 
  "index", "name", "description", "active", 
  "admission_time", "discussion_time", "verification_time", "voting_time", 
  "issue_quorum_num", "issue_quorum_den", 
  "initiative_quorum_num", "initiative_quorum_den", 
  "majority_num", "majority_den", "majority_strict"
)

policy:save()

slot.put_into("notice", _"Policy successfully updated")

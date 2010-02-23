local initiative = param.get("initiative", "table")

if initiative.revoked then
  slot.put(_"Not voted (revoked from initiator)")
elseif initiative.admitted == false then
  slot.put(_"Not voted (not admitted)")
else

  execute.view{
    module = "initiative",
    view = "_battles",
    params = { initiative = initiative }
  }

  ui.container{
    attr = { class = "heading" },
    content = _"Member voting"
  }

  execute.view{
    module = "member",
    view = "_list",
    params = {
      initiative = initiative,
      members_selector =  initiative.issue:get_reference_selector("direct_voters")
        :left_join("vote", nil, { "vote.initiative_id = ? AND vote.member_id = member.id", initiative.id })
        :add_field("direct_voter.weight as voter_weight")
        :add_field("coalesce(vote.grade, 0) as grade")
    }
  }

end

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

  slot.put("<br />")
  
  ui.container{
    attr = { class = "heading" },
    content = _"Member voting"
  }

  execute.view{
    module = "member",
    view = "_list",
    params = {
      initiative = initiative,
      for_votes = true,
      members_selector =  initiative.issue:get_reference_selector("direct_voters")
        :left_join("vote", nil, { "vote.initiative_id = ? AND vote.member_id = member.id", initiative.id })
        :add_field("direct_voter.weight as voter_weight")
        :add_field("coalesce(vote.grade, 0) as grade")
        :left_join("initiative", nil, "initiative.id = vote.initiative_id")
        :left_join("issue", nil, "issue.id = initiative.issue_id")
    }
  }

  slot.put("<br />")
  
  ui.container{
    attr = { class = "heading" },
    content = _"Voting details"
  }
  
  ui.form{
    attr = { class = "vertical" },
    content = function()
 
    ui.field.boolean{ label = _"Direct majority", value = initiative.direct_majority }
    ui.field.boolean{ label = _"Indirect majority", value = initiative.indirect_majority }
    ui.field.text{ label = _"Schulze rank", value = tostring(initiative.schulze_rank) .. " (" .. _("Status quo: #{rank}", { rank = initiative.issue.status_quo_schulze_rank }) .. ")" }
    local texts = {}
    if initiative.reverse_beat_path then
      texts[#texts+1] = _"reverse beat path to status quo (including ties)"
    end
    if initiative.multistage_majority then
      texts[#texts+1] = _"possibly instable result caused by multistage majority"
    end
    if #texts == 0 then
     texts[#texts+1] = _"none"
    end
    ui.field.text{
      label = _"Other failures",
      value = table.concat(texts, ", ")
    }
    ui.field.boolean{ label = _"Eligible as winner", value = initiative.eligible }
  end
}


end

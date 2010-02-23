local initiative = param.get("initiative", "table")

link_area(initiative.issue.area)

link_issue(initiative.issue)

ui.link{
  external = "",
  attr = {
    style = "display: block; text-decoration: none;",
    name = "initiative_" .. tostring(initiative.id),
  },
  content = function()
    ui.heading{
      content = _("##{issue_id}.#{id} #{name}", { issue_id = initiative.issue.id, id = initiative.id, name = initiative.shortened_name })
    }
  end
}

slot.put("<br />")

if initiative.issue.ranks_available and initiative.admitted then
  local class = initiative.rank == 1 and "admitted_info" or "not_admitted_info"
  ui.container{
    attr = { class = class },
    content = function()
      local max_value = initiative.issue.voter_count
      slot.put("&nbsp;")
      local positive_votes = initiative.positive_votes
      local negative_votes = initiative.negative_votes
      slot.put(_"Yes" .. ": <b>" .. tostring(positive_votes) .. "</b>")
      slot.put(" &middot; ")
      slot.put(_"Abstention" .. ": <b>" .. tostring(max_value - initiative.negative_votes - initiative.positive_votes)  .. "</b>")
      slot.put(" &middot; ")
      slot.put(_"No" .. ": <b>" .. tostring(initiative.negative_votes) .. "</b>")
      slot.put(" &middot; ")
      slot.put("<b>")
      if initiative.rank == 1 then
        slot.put(_"Approved")
      elseif initiative.rank then
        slot.put(_("Not approved (rank #{rank})", { rank = initiative.rank }))
      else
        slot.put(_"Not approved")
      end
      slot.put("</b>")
    end
  }
end

if initiative.issue.state == "cancelled" then
  local policy = initiative.issue.policy
  ui.container{
    attr = { class = "not_admitted_info" },
    content = _("This issue has been cancelled. It failed the quorum of #{quorum}.", { quorum = format.percentage(policy.issue_quorum_num / policy.issue_quorum_den) })
  }
elseif initiative.admitted == false then
  local policy = initiative.issue.policy
  ui.container{
    attr = { class = "not_admitted_info" },
    content = _("This initiative has not been admitted! It failed the quorum of #{quorum}.", { quorum = format.percentage(policy.initiative_quorum_num / policy.initiative_quorum_den) })
  }
end

if initiative.revoked then
  ui.container{
    attr = { class = "revoked_info" },
    content = function()
      slot.put(_("This initiative has been revoked at #{revoked}", { revoked = format.timestamp(initiative.revoked) }))
    end
  }
end


ui.container{
  attr = { class = "draft_content wiki" },
  content = function()
    slot.put(format.wiki_text(initiative.current_draft.content, initiative.current_draft.formatting_engine))
  end
}

execute.view{
  module = "initiative",
  view = "_battles",
  params = { initiative = initiative }
}


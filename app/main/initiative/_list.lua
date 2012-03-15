local issue = param.get("issue", "table")

local initiatives_selector = param.get("initiatives_selector", "table")

local highlight_initiative = param.get("highlight_initiative", "table")

local for_member = param.get("for_member", "table") or app.session.member

initiatives_selector
  :join("issue", nil, "issue.id = initiative.issue_id")

if app.session.member_id then
  initiatives_selector
    :left_join("initiator", "_initiator", { "_initiator.initiative_id = initiative.id AND _initiator.member_id = ? AND _initiator.accepted", for_member.id } )
    :left_join("supporter", "_supporter", { "_supporter.initiative_id = initiative.id AND _supporter.member_id = ?", for_member.id} )
    :left_join("delegating_interest_snapshot", "_delegating_interest_snapshot", { "_delegating_interest_snapshot.issue_id = initiative.issue_id AND _delegating_interest_snapshot.member_id = ? AND _delegating_interest_snapshot.event = issue.latest_snapshot_event", for_member.id} )
    :left_join("direct_supporter_snapshot", "_direct_supporter_snapshot", "_direct_supporter_snapshot.initiative_id = initiative.id AND _direct_supporter_snapshot.member_id = _delegating_interest_snapshot.delegate_member_ids[array_upper(_delegating_interest_snapshot.delegate_member_ids, 1)] AND _direct_supporter_snapshot.event = issue.latest_snapshot_event")

    :add_field("(_initiator.member_id NOTNULL)", "is_initiator")
    :add_field({"(_supporter.member_id NOTNULL) AND NOT EXISTS(SELECT 1 FROM opinion WHERE opinion.initiative_id = initiative.id AND opinion.member_id = ? AND ((opinion.degree = 2 AND NOT fulfilled) OR (opinion.degree = -2 AND fulfilled)))", for_member.id }, "is_supporter")
    :add_field({"EXISTS(SELECT 1 FROM opinion WHERE opinion.initiative_id = initiative.id AND opinion.member_id = ? AND ((opinion.degree = 2 AND NOT fulfilled) OR (opinion.degree = -2 AND fulfilled)))", for_member.id }, "is_potential_supporter")

    :add_field("_direct_supporter_snapshot.member_id NOTNULL", "is_supporter_via_delegation")
end

initiatives_selector:add_order_by("initiative.rank, initiative.supporter_count DESC, initiative.id")

local initiatives_count = initiatives_selector:count()

local limit = param.get("limit", atom.number)

local more_initiatives_count
if limit then
  if initiatives_count > limit then
    more_initiatives_count = initiatives_count - limit
  end
  initiatives_selector:limit(limit)
end

local issue = param.get("issue", "table")

local name = "initiative_list"
if issue then
  name = "issue_" .. tostring(issue.id) ..  "_initiative_list"
end

ui.add_partial_param_names{ name }

ui.paginate{
  name = issue and "issue_" .. tostring(issue.id) .. "_page" or nil,
  selector = initiatives_selector,
  per_page = param.get("per_page", atom.number) or limit or 25,
  content = function()
    local initiatives = initiatives_selector:exec()
    if highlight_initiative then
      local highlight_initiative_found
      for i, initiative in ipairs(initiatives) do
        if initiative.id == highlight_initiative.id then
          highhighlight_initiative_found = true
        end
      end
      if not highhighlight_initiative_found then
        initiatives[#initiatives+1] = highlight_initiative
        if more_initiatives_count then
          more_initiatives_count = more_initiatives_count - 1
        end
      end
    end
    for i, initiative in ipairs(initiatives) do
      execute.view{
        module = "initiative",
        view = "_list_element",
        params = {
          initiative = initiative,
          selected = highlight_initiative and highlight_initiative.id == initiative.id or nil,
        }
      }
    end
  end
}

if more_initiatives_count and more_initiatives_count > 0 then
  local text
  if more_initiatives_count == 1 then
    text = _("and one more initiative")
  else
    text = _("and #{count} more initiatives", { count = more_initiatives_count })
  end
  ui.link{
    attr = { class = "more_initiatives_link" },
    content = text,
    module = "issue",
    view = "show",
    id = issue.id,
  }
end

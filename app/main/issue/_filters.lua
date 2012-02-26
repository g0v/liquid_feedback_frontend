local member = param.get("member", "table")

local filters = {}

-- FIXME: the filter should be named like the corresponding issue.state value

filters[#filters+1] = {
  name = "filter",
  {
    name = "any",
    label = _"Any phase",
    selector_modifier = function(selector) end
  },
  {
    name = "open",
    label = _"Open",
    selector_modifier = function(selector)
      selector:add_where("issue.closed ISNULL")
    end
  },
  {
    name = "new",
    label = _"New",
    selector_modifier = function(selector)
      selector:add_where("issue.accepted ISNULL AND issue.closed ISNULL")
    end
  },
  {
    name = "accepted",
    label = _"Discussion",
    selector_modifier = function(selector)
      selector:add_where("issue.accepted NOTNULL AND issue.half_frozen ISNULL AND issue.closed ISNULL")
    end
  },
  {
    name = "half_frozen",
    label = _"Frozen",
    selector_modifier = function(selector)
      selector:add_where("issue.half_frozen NOTNULL AND issue.fully_frozen ISNULL")
    end
  },
  {
    name = "frozen",
    label = _"Voting",
    selector_modifier = function(selector)
      selector:add_where("issue.fully_frozen NOTNULL AND issue.closed ISNULL")
      filter_voting = true
    end
  },
  {
    name = "finished",
    label = _"Finished",
    selector_modifier = function(selector)
      selector:add_where("issue.closed NOTNULL AND issue.fully_frozen NOTNULL")
    end
  },
  {
    name = "cancelled",
    label = _"Cancelled",
    selector_modifier = function(selector)
      selector:add_where("issue.closed NOTNULL AND issue.fully_frozen ISNULL")
    end
  }
}


if not param.get("no_sort", atom.boolean) then
  
  local filter = { name = "order" }
  
  local text = _"Time left"
  local f = param.get_all_cgi()["filter"]
  if f == "finished" or f == "cancelled" then
    text = _"Recently closed"
  end
  filter[#filter+1] = {
    name = "state_time",
    label = text,
    selector_modifier = function(selector)
      selector:add_order_by("issue.closed DESC, coalesce(issue.fully_frozen + issue.voting_time, issue.half_frozen + issue.verification_time, issue.accepted + issue.discussion_time, issue.created + issue.admission_time) - now()")
    end
  }

  filter[#filter+1] =  {
    name = "latest",
    label = _"Latest",
    selector_modifier = function(selector)
      selector:add_order_by("issue.created DESC")
    end
  }
  
  filter[#filter+1] = {
    name = "max_potential_support",
    label = _"Supporter count",
    selector_modifier = function(selector)
      selector:add_order_by("(SELECT max(supporter_count) FROM initiative WHERE initiative.issue_id = issue.id) DESC")
    end
  }
  
  filters[#filters+1] = filter
  
end

if app.session.member then
  local filter = {
    name = "filter_interest",
    {
      name = "any",
      label = _"Any",
      selector_modifier = function()  end
    },
    {
      name = "my",
      label = _"Interested",
      selector_modifier = function() end
    },
    {
      name = "supported",
      label = _"Supported",
      selector_modifier = function() end
    },
    {
      name = "potentially_supported",
      label = _"Potentially supported",
      selector_modifier = function() end
    },
    {
      name = "initiated",
      label = _"Initiated",
      selector_modifier = function(selector)
        selector:add_where({ "EXISTS (SELECT 1 FROM initiative JOIN initiator ON initiator.initiative_id = initiative.id AND initiator.member_id = ? AND initiator.accepted WHERE initiative.issue_id = issue.id)", member.id })
      end
    },
  }

  --[[
  if param.get_all_cgi()["filter"] == "finished" then
    filter[#filter+1] = {
      name = "voted",
      label = _"Voted",
      selector_modifier = function(selector)
        selector:add_where({ "EXISTS (SELECT 1 FROM vote WHERE vote.issue_id = issue.id AND vote.member_id = ?)", member.id })
      end
    }
  end
  --]]

  filters[#filters+1] = filter

  local filter_interest = param.get_all_cgi()["filter_interest"]
    
  if filter_interest ~= "any" and filter_interest ~= nil and filter_interest ~= "initiated" then
    filters[#filters+1] = {
      name = "filter_delegation",
      {
        name = "any",
        label = _"Direct and by delegation",
        selector_modifier = function(selector)
          if filter_interest == "my" then
            selector:left_join("delegating_interest_snapshot", "filter_interest", { "filter_interest.issue_id = issue.id AND filter_interest.member_id = ? AND filter_interest.event = issue.latest_snapshot_event", member.id })
            selector:left_join("interest", "filter_delegating_interest", { "filter_delegating_interest.issue_id = issue.id AND filter_delegating_interest.member_id = ? ", member.id })
            selector:add_where{ "filter_interest.member_id NOTNULL OR filter_delegating_interest.member_id NOTNULL" }
          elseif filter_interest == "supported" then
            selector:add_where({ "EXISTS (SELECT 1 FROM initiative JOIN supporter ON supporter.initiative_id = initiative.id AND supporter.member_id = ? LEFT JOIN critical_opinion ON critical_opinion.initiative_id = initiative.id AND critical_opinion.member_id = ? WHERE initiative.issue_id = issue.id AND critical_opinion.member_id ISNULL LIMIT 1) OR EXISTS (SELECT 1 FROM initiative JOIN direct_supporter_snapshot ON direct_supporter_snapshot.initiative_id = initiative.id AND direct_supporter_snapshot.event = issue.latest_snapshot_event JOIN delegating_interest_snapshot ON delegating_interest_snapshot.delegate_member_ids[array_upper(delegating_interest_snapshot.delegate_member_ids, 1)] = direct_supporter_snapshot.member_id AND delegating_interest_snapshot.issue_id = issue.id AND delegating_interest_snapshot.member_id = ? AND delegating_interest_snapshot.event = issue.latest_snapshot_event WHERE initiative.issue_id = issue.id AND direct_supporter_snapshot.satisfied LIMIT 1)", member.id, member.id, member.id })
          elseif filter_interest == "potentially_supported" then
            selector:add_where({ "EXISTS (SELECT 1 FROM initiative JOIN supporter ON supporter.initiative_id = initiative.id AND supporter.member_id = ? JOIN critical_opinion ON critical_opinion.initiative_id = initiative.id AND critical_opinion.member_id = ? WHERE initiative.issue_id = issue.id LIMIT 1) OR EXISTS (SELECT 1 FROM initiative JOIN direct_supporter_snapshot ON direct_supporter_snapshot.initiative_id = initiative.id AND direct_supporter_snapshot.event = issue.latest_snapshot_event JOIN delegating_interest_snapshot ON delegating_interest_snapshot.delegate_member_ids[array_upper(delegating_interest_snapshot.delegate_member_ids, 1)] = direct_supporter_snapshot.member_id AND delegating_interest_snapshot.issue_id = issue.id AND delegating_interest_snapshot.member_id = ? AND delegating_interest_snapshot.event = issue.latest_snapshot_event WHERE initiative.issue_id = issue.id AND NOT direct_supporter_snapshot.satisfied LIMIT 1)", member.id, member.id, member.id, member.id })
          end
        end
      },
      {
        name = "direct",
        label = _"Direct",
        selector_modifier = function(selector)
          if filter_interest == "my" then
            selector:join("interest", "filter_interest", { "filter_interest.issue_id = issue.id AND filter_interest.member_id = ? ", member.id })
          elseif filter_interest == "supported" then
            selector:add_where({ "EXISTS (SELECT 1 FROM initiative JOIN supporter ON supporter.initiative_id = initiative.id AND supporter.member_id = ? LEFT JOIN critical_opinion ON critical_opinion.initiative_id = initiative.id AND critical_opinion.member_id = ? WHERE initiative.issue_id = issue.id AND critical_opinion.member_id ISNULL LIMIT 1)", member.id, member.id })
          elseif filter_interest == "potentially_supported" then
            selector:add_where({ "EXISTS (SELECT 1 FROM initiative JOIN supporter ON supporter.initiative_id = initiative.id AND supporter.member_id = ? JOIN critical_opinion ON critical_opinion.initiative_id = initiative.id AND critical_opinion.member_id = ? WHERE initiative.issue_id = issue.id LIMIT 1)", member.id, member.id })
          end
        end
      },
      {
        name = "delegated",
        label = _"By delegation",
        selector_modifier = function(selector)
          if filter_interest == "my" then
            selector:join("delegating_interest_snapshot", "filter_interest", { "filter_interest.issue_id = issue.id AND filter_interest.member_id = ? AND filter_interest.event = issue.latest_snapshot_event", member.id })
          elseif filter_interest == "supported" then
            selector:add_where({ "EXISTS (SELECT 1 FROM initiative JOIN direct_supporter_snapshot ON direct_supporter_snapshot.initiative_id = initiative.id AND direct_supporter_snapshot.event = issue.latest_snapshot_event JOIN delegating_interest_snapshot ON delegating_interest_snapshot.delegate_member_ids[array_upper(delegating_interest_snapshot.delegate_member_ids, 1)] = direct_supporter_snapshot.member_id AND delegating_interest_snapshot.issue_id = issue.id AND delegating_interest_snapshot.member_id = ? AND delegating_interest_snapshot.event = issue.latest_snapshot_event WHERE initiative.issue_id = issue.id AND direct_supporter_snapshot.satisfied LIMIT 1)", member.id })
          elseif filter_interest == "potentially_supported" then
            selector:add_where({ "EXISTS (SELECT 1 FROM initiative JOIN direct_supporter_snapshot ON direct_supporter_snapshot.initiative_id = initiative.id AND direct_supporter_snapshot.event = issue.latest_snapshot_event JOIN delegating_interest_snapshot ON delegating_interest_snapshot.delegate_member_ids[array_upper(delegating_interest_snapshot.delegate_member_ids, 1)] = direct_supporter_snapshot.member_id AND delegating_interest_snapshot.issue_id = issue.id AND delegating_interest_snapshot.member_id = ? AND delegating_interest_snapshot.event = issue.latest_snapshot_event WHERE initiative.issue_id = issue.id AND NOT direct_supporter_snapshot.satisfied LIMIT 1)", member.id, member.id })
          end
        end
      }
    }
  end

end

if app.session.member and member.id == app.session.member_id and (param.get_all_cgi()["filter"] == "frozen") then
  filters[#filters+1] = {
    name = "filter_voting",
    {
      name = "any",
      label = _"Any",
      selector_modifier = function()  end
    },
    {
      name = "not_voted",
      label = _"Not voted",
      selector_modifier = function(selector)
        selector:left_join("direct_voter", nil, { "direct_voter.issue_id = issue.id AND direct_voter.member_id = ?", member.id })
        selector:add_where("direct_voter.member_id ISNULL")
      end
    },
    {
      name = "voted",
      label = _"Voted",
      selector_modifier = function(selector)
        selector:join("direct_voter", nil, { "direct_voter.issue_id = issue.id AND direct_voter.member_id = ?", member.id })
      end
    },
  }
end

function filters:get_filter(group, name)
  for i,grp in ipairs(self) do
    if grp.name == group then
      for i,entry in ipairs(grp) do
        if entry.name == name then
          return entry
        end
      end
    end
  end
end

return filters
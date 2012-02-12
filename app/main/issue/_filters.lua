local filters = {}

-- FIXME: the filter should be named like the corresponding issue.state value

filters[#filters+1] = {
  name = "filter",
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
    label = _"In discussion",
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
  },
  {
    name = "any",
    label = _"Any",
    selector_modifier = function(selector) end
  },
}


filters[#filters+1] = {
  name = "filter_interest",
  {
    name = "any",
    label = _"Any",
    selector_modifier = function()  end
  },
  {
    name = "my",
    label = _"Interested",
    selector_modifier = function(selector)
      selector:join("interest", "filter_interest", { "filter_interest.issue_id = issue.id AND filter_interest.member_id = ? ", app.session.member.id })
    end
  },
  {
    name = "supported",
    label = _"Supported",
    selector_modifier = function(selector)
      selector:add_where({ "EXISTS (SELECT 1 FROM initiative JOIN supporter ON supporter.initiative_id = initiative.id AND supporter.member_id = ? LEFT JOIN opinion ON opinion.initiative_id = initiative.id AND opinion.member_id = ? AND ((opinion.degree = 2 AND NOT fulfilled) OR (opinion.degree = -2 AND fulfilled)) WHERE initiative.issue_id = issue.id AND opinion.member_id ISNULL LIMIT 1)", app.session.member.id, app.session.member.id })
    end
  },
  {
    name = "potentially_supported",
    label = _"Potential supported",
    selector_modifier = function(selector)
      selector:add_where({ "EXISTS (SELECT 1 FROM initiative JOIN supporter ON supporter.initiative_id = initiative.id AND supporter.member_id = ? JOIN opinion ON opinion.initiative_id = initiative.id AND opinion.member_id = ? AND ((opinion.degree = 2 AND NOT fulfilled) OR (opinion.degree = -2 AND fulfilled)) WHERE initiative.issue_id = issue.id LIMIT 1)", app.session.member.id, app.session.member.id })
    end
  },
  {
    name = "initiated",
    label = _"Initiated",
    selector_modifier = function(selector)
      selector:add_where({ "EXISTS (SELECT 1 FROM initiative JOIN initiator ON initiator.initiative_id = initiative.id AND initiator.member_id = ? WHERE initiative.issue_id = issue.id)", app.session.member.id })
    end
  },
}

if not param.get("no_sort", atom.boolean) then
  
  local filter = { name = "order" }
  
  local text = _"Time left"
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

  filter[#filter+1] = {
    name = "max_potential_support",
    label = _"Supporter count",
    selector_modifier = function(selector)
      selector:add_order_by("(SELECT max(supporter_count) FROM initiative WHERE initiative.issue_id = issue.id) DESC")
    end
  }
  
  filter[#filter+1] =  {
    name = "newest",
    label = _"Newest",
    selector_modifier = function(selector)
      selector:add_order_by("issue.created DESC")
    end
  }
  
  filters[#filters+1] = filter
  
end

if app.session.member and param.get("filter") == "frozen" then
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
        selector:left_join("direct_voter", nil, { "direct_voter.issue_id = issue.id AND direct_voter.member_id = ?", app.session.member.id })
        selector:add_where("direct_voter.member_id ISNULL")
      end
    },
    {
      name = "voted",
      label = _"Voted",
      selector_modifier = function(selector)
        selector:join("direct_voter", nil, { "direct_voter.issue_id = issue.id AND direct_voter.member_id = ?", app.session.member.id })
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
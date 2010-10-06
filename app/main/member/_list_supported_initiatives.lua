local initiatives_selector = param.get("initiatives_selector", "table")
local member = param.get("member", "table")

local filters  = {
  {
    label = _"Filter",
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
}


if member then
  filters[#filters+1] = {
    label = _"Support",
    name = "support",
    {
      name = "any",
      label = _"Any",
      selector_modifier = function(selector)
      end
    },
    {
      name = "potential",
      label = _"Potential supported",
      selector_modifier = function(selector)
        -- not even having is_potential_supporter is working here :-( hopefully the optimizer will work it out...
        selector:add_where({"EXISTS(SELECT 1 FROM opinion WHERE opinion.initiative_id = initiative.id AND opinion.member_id = ? AND ((opinion.degree = 2 AND NOT fulfilled) OR (opinion.degree = -2 AND fulfilled)))", member.id })
      end
    },
    {
      name = "supporter",
      label = _"Supporter",
      selector_modifier = function(selector)
        selector:add_where({"NOT EXISTS(SELECT 1 FROM opinion WHERE opinion.initiative_id = initiative.id AND opinion.member_id = ? AND ((opinion.degree = 2 AND NOT fulfilled) OR (opinion.degree = -2 AND fulfilled)))", member.id })
      end
    },
  }
end

filters.label = _"Filter"
filters.name = "filter_voting"
filters.selector = initiatives_selector
filters.content = function()
    execute.view{
      module = "initiative",
      view = "_list",
      params = { initiatives_selector = initiatives_selector }
    }
  end


ui.filters(filters)

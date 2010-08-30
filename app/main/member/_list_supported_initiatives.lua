local initiatives_selector = param.get("initiatives_selector", "table")

ui.filters{
  label = _"Filter",
  name = "filter_voting",
  selector = initiatives_selector,
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
  },
  content = function()
    execute.view{
      module = "initiative",
      view = "_list",
      params = { initiatives_selector = initiatives_selector }
    }
  end
}

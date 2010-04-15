local issues_selector = param.get("issues_selector", "table")

if app.session.member_id then
  issues_selector
    :left_join("interest", "_interest", { "_interest.issue_id = issue.id AND _interest.member_id = ?", app.session.member.id} )
    :add_field("(_interest.member_id NOTNULL)", "is_interested")
end

ui.add_partial_param_names{
  "filter",
  "filter_open",
  "filter_voting",
  "filter_interest",
  "issue_list" 
}

local filters = {}

filters[#filters+1] = {
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


if param.get("filter") == "frozen" then
  filters[#filters+1] = {
    label = _"Filter",
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


filters[#filters+1] = {
  label = _"Filter",
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
  filters[#filters+1] = {
    label = _"Order by",
    name = "issue_list",
    {
      name = "max_potential_support",
      label = _"Max potential support",
      selector_modifier = function(selector)
        selector:add_order_by("(SELECT max(supporter_count) FROM initiative WHERE initiative.issue_id = issue.id) DESC")
      end
    },
    {
      name = "max_support",
      label = _"Max support",
      selector_modifier = function(selector)
        selector:add_order_by("(SELECT max(satisfied_supporter_count) FROM initiative WHERE initiative.issue_id = issue.id) DESC")
      end
    },
    {
      name = "population",
      label = _"Population",
      selector_modifier = function(selector)
        selector:add_order_by("issue.population DESC")
      end
    },
    {
      name = "newest",
      label = _"Newest",
      selector_modifier = function(selector)
        selector:add_order_by("issue.created DESC")
      end
    },
    {
      name = "oldest",
      label = _"Oldest",
      selector_modifier = function(selector)
        selector:add_order_by("issue.created")
      end
    }
  }
end

filters.content = function()
  local ui_paginate = ui.paginate
  if param.get("per_page") == "all" then
    ui_paginate = function(args) args.content() end
  end
  ui_paginate{
    per_page = tonumber(param.get("per_page")),
    selector = issues_selector,
    content = function()
      local highlight_string = param.get("highlight_string", "string")
      local issues = issues or issues_selector:exec()
      -- issues:load(initiatives)
      ui.list{
        attr = { class = "issues" },
        records = issues,
        columns = {
          {
            label = _"Issue",
            content = function(record)
              if not param.get("for_area_list", atom.boolean) then
                ui.field.text{
                  value = record.area.name
                }
                slot.put("<br />")
              end
              if record.is_interested then
                local label = _"You are interested in this issue",
                ui.image{
                  attr = { alt = label, title = label },
                  static = "icons/16/eye.png"
                }
                slot.put("&nbsp;")
              end
              ui.link{
                text = _("Issue ##{id}", { id = tostring(record.id) }),
                module = "issue",
                view = "show",
                id = record.id
              }
              if record.state == "new" then
                ui.image{
                  static = "icons/16/new.png"
                }
              end
              slot.put("<br />")
              slot.put("<br />")
              if record.old_state then
                ui.field.text{ value = format.time(record.sort) }
                ui.field.text{ value = Issue:get_state_name_for_state(record.old_state) .. " > " .. Issue:get_state_name_for_state(record.new_state) }
              else
              end
            end
          },
          {
            label = _"State",
            content = function(record)
              if record.state == "voting" then
                ui.link{
                  content = _"Voting",
                  module = "vote",
                  view = "list",
                  params = { issue_id = record.id }
                }
              else
                ui.field.issue_state{ value = record.state }
              end
            end
          },
          {
            label = _"Initiatives",
            content = function(record)
              local initiatives_selector = record:get_reference_selector("initiatives")
              local highlight_string = param.get("highlight_string")
              if highlight_string then
                initiatives_selector:add_field( {'"highlight"("initiative"."name", ?)', highlight_string }, "name_highlighted")
              end
              execute.view{
                module = "initiative",
                view = "_list",
                params = {
                  issue = record,
                  initiatives_selector = initiatives_selector,
                  highlight_string = highlight_string,
                  per_page = app.session.member_id and tonumber(app.session.member:get_setting_value("initiatives_preview_limit") or 3) or 3,
                  no_sort = true,
                  limit = app.session.member_id and tonumber(app.session.member:get_setting_value("initiatives_preview_limit") or 3) or 3
                }
              }
            end
          },
        }
      }
    end
  }
end

filters.selector = issues_selector
filters.label = _"Change filters and order"

if param.get("no_filter", atom.boolean) then
  filters.content()
else
  ui.filters(filters)
end

if param.get("legend", atom.boolean) ~= false then
  local filter = param.get_all_cgi().filter
  if not filter or filter == "any" or filter ~= "finished" then
    ui.bargraph_legend{
      width = 25,
      bars = {
        { color = "#0a0", label = _"Supporter" },
        { color = "#777", label = _"Potential supporter" },
        { color = "#ddd", label = _"No support at all" },
      }
    }
  end
  if not filter or filter == "any" or filter == "finished" then
    ui.bargraph_legend{
      width = 25,
      bars = {
        { color = "#0a0", label = _"Yes" },
        { color = "#aaa", label = _"Abstention" },
        { color = "#a00", label = _"No" },
      }
    }
  end
end


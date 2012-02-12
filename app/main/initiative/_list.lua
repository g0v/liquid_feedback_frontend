ui.script{ script = "lf_initiative_expanded = {};" }

local issue = param.get("issue", "table")

local initiatives_selector = param.get("initiatives_selector", "table")

local highlight_initiative = param.get("highlight_initiative", "table")

initiatives_selector
  :join("issue", nil, "issue.id = initiative.issue_id")

if app.session.member_id then
  initiatives_selector
    :left_join("initiator", "_initiator", { "_initiator.initiative_id = initiative.id AND _initiator.member_id = ? AND _initiator.accepted", app.session.member.id} )
    :left_join("supporter", "_supporter", { "_supporter.initiative_id = initiative.id AND _supporter.member_id = ?", app.session.member.id} )
  
    :add_field("(_initiator.member_id NOTNULL)", "is_initiator")
    :add_field({"(_supporter.member_id NOTNULL) AND NOT EXISTS(SELECT 1 FROM opinion WHERE opinion.initiative_id = initiative.id AND opinion.member_id = ? AND ((opinion.degree = 2 AND NOT fulfilled) OR (opinion.degree = -2 AND fulfilled)))", app.session.member.id }, "is_supporter")
    :add_field({"EXISTS(SELECT 1 FROM opinion WHERE opinion.initiative_id = initiative.id AND opinion.member_id = ? AND ((opinion.degree = 2 AND NOT fulfilled) OR (opinion.degree = -2 AND fulfilled)))", app.session.member.id }, "is_potential_supporter")
end

local initiatives_count = initiatives_selector:count()

local limit = param.get("limit", atom.number)
local no_sort = param.get("no_sort", atom.boolean)

local show_for_issue = param.get("show_for_issue", atom.boolean)

local show_for_initiative

local show_for_initiative_id = param.get("for_initiative_id", atom.number)

if show_for_initiative_id then
  show_for_initiative = Initiative:by_id(show_for_initiative_id)

elseif not show_for_initiative_id and show_for_issue and issue and issue.ranks_available then
  winning_initiative = Initiative:new_selector()
    :add_where{ "issue_id = ?", issue.id }
    :add_where("rank = 1")
    :optional_object_mode()
    :exec()
  if winning_initiative then
    show_for_initiative = winning_initiative
    ui.container{
      attr = { class = "admitted_info" },
      content = _"This issue has been finished with the following winning initiative:"
    }
  else
    ui.container{
      attr = { class = "not_admitted_info" },
      content = _"This issue has been finished without any winning initiative."
    }
  end
end


if show_for_initiative then
  ui.script{ script = "lf_initiative_expanded['initiative_content_" .. tostring(show_for_initiative.id) .. "'] = true;" }
  initiatives_selector:add_where{ "initiative.id != ?", show_for_initiative.id }

  execute.view{
    module = "initiative",
    view = "_list_element",
    params = {
      initiative = show_for_initiative,
      expanded = true,
      expandable = true
    }
  }
  if show_for_issue then
    slot.put("<br />")
    ui.container{
      attr = { style = "font-weight: bold;" },
      content = function()
        slot.put(_"Alternative initiatives")
      end
    }
  end
elseif show_for_issue then
  ui.container{
    attr = { style = "font-weight: bold;" },
    content = function()
      slot.put(_"Alternative initiatives")
    end
  }
end

if not show_for_initiative or initiatives_count > 1 then


  local more_initiatives_count
  if limit then
    limit = limit - (show_for_initiative and 1 or 0)
    if initiatives_count > limit then
      more_initiatives_count = initiatives_count - limit
    end
    initiatives_selector:limit(limit)
  end

  local expandable = param.get("expandable", atom.boolean)

  local issue = param.get("issue", "table")

  local name = "initiative_list"
  if issue then
    name = "issue_" .. tostring(issue.id) ..  "_initiative_list"
  end

  ui.add_partial_param_names{ name }

  local order_filter = {
    name = name,
    label = _"Order by"
  }

  if issue and issue.ranks_available then
    order_filter[#order_filter+1] = {
      name = "rank",
      label = _"Rank",
      selector_modifier = function(selector) selector:add_order_by("initiative.rank, initiative.admitted DESC, vote_ratio(initiative.positive_votes, initiative.negative_votes) DESC, initiative.id") end
    }
  end

  order_filter[#order_filter+1] = {
    name = "potential_support",
    label = _"Potential support",
    selector_modifier = function(selector) selector:add_order_by("CASE WHEN issue.population = 0 THEN 0 ELSE initiative.supporter_count::float / issue.population::float END DESC, initiative.id") end
  }

  order_filter[#order_filter+1] = {
    name = "support",
    label = _"Support",
    selector_modifier = function(selector) selector:add_order_by("initiative.satisfied_supporter_count::float / issue.population::float DESC, initiative.id") end
  }

  order_filter[#order_filter+1] = {
    name = "newest",
    label = _"Newest",
    selector_modifier = function(selector) selector:add_order_by("initiative.created DESC, initiative.id") end
  }

  order_filter[#order_filter+1] = {
    name = "oldest",
    label = _"Oldest",
    selector_modifier = function(selector) selector:add_order_by("initiative.created, initiative.id") end
  }

  ui_filters = ui.filters

  if no_sort then
    ui_filters = function(args) args.content() end
    if issue.ranks_available then
      initiatives_selector:add_order_by("initiative.rank, initiative.admitted DESC, vote_ratio(initiative.positive_votes, initiative.negative_votes) DESC, initiative.id")
    else
      initiatives_selector:add_order_by("CASE WHEN issue.population = 0 OR initiative.supporter_count = 0 OR initiative.supporter_count ISNULL THEN 0 ELSE initiative.supporter_count::float / issue.population::float END DESC, initiative.id")
    end
  end

  ui_filters{
    label = _"Change order",
    order_filter,
    selector = initiatives_selector,
    content = function()
      ui.paginate{
        name = issue and "issue_" .. tostring(issue.id) .. "_page" or nil,
        selector = initiatives_selector,
        per_page = param.get("per_page", atom.number) or limit,
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
            local expanded = config.user_tab_mode == "accordeon_all_expanded" and expandable or
              show_for_initiative and initiative.id == show_for_initiative.id
            if expanded then
              ui.script{ script = "lf_initiative_expanded['initiative_content_" .. tostring(initiative.id) .. "'] = true;" }
            end
            execute.view{
              module = "initiative",
              view = "_list_element",
              params = {
                initiative = initiative,
                selected = highlight_initiative and highlight_initiative.id == initiative.id or nil,
                expanded = expanded,
                expandable = expandable
              }
            }
          end
        end
      }
    end
  }

  if more_initiatives_count then
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

end

if show_for_issue then
  slot.put("<br />")
  
  if issue and initiatives_count == 1 then
    ui.container{
      content = function()
        if issue.fully_frozen or issue.closed then
          slot.put(_"There were no more alternative initiatives.")
        else
          slot.put(_"There are no more alternative initiatives currently.")
        end
      end
    }
  end

end

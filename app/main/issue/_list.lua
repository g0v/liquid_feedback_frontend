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

local filters = execute.load_chunk{module="issue", chunk="_filters.lua"}

filters.content = function()
  ui.paginate{
    per_page = tonumber(param.get("per_page")),
    selector = issues_selector,
    content = function()
      local highlight_string = param.get("highlight_string", "string")
      local issues = issues or issues_selector:exec()
      -- issues:load(initiatives)
      ui.container{ attr = { class = "issues" }, content = function()

        for i, issue in ipairs(issues) do

          local class = "issue"
          if issue.is_interested then
            class = class .. " interested"
          end
          ui.container{ attr = { class = class }, content = function()

            ui.container{ attr = { class = "issue_info" }, content = function()
            
              ui.tag{
                tag = "div",
                content = function()
                  ui.link{
                    attr = { class = "issue_id" },
                    text = _("Issue ##{id}", { id = tostring(issue.id) }),
                    module = "issue",
                    view = "show",
                    id = issue.id
                  }

                  slot.put(" &middot; ")
                  ui.tag{ content = issue.area.name }
                  slot.put(" &middot; ")
                  ui.tag{ content = issue.area.unit.name }

              end
              }
              ui.tag{
                tag = "div",
                content = function()
                
                  ui.tag{ content = issue.policy.name }

                  slot.put(" &middot; ")
                  ui.tag{ content = issue.state_name }

                  if issue.state_time_left then
                    slot.put(" &middot; ")
                    ui.tag{ content = _("#{time_left} left", { time_left = issue.state_time_left }) }
                  end

                end
              }

              
              if issue.old_state then
                ui.field.text{ value = format.time(issue.sort) }
                ui.field.text{ value = Issue:get_state_name_for_state(issue.old_state) .. " > " .. Issue:get_state_name_for_state(issue.new_state) }
              else
              end
            end }

            ui.container{ attr = { class = "initiative_list" }, content = function()

              local initiatives_selector = issue:get_reference_selector("initiatives")
              local highlight_string = param.get("highlight_string")
              if highlight_string then
                initiatives_selector:add_field( {'"highlight"("initiative"."name", ?)', highlight_string }, "name_highlighted")
              end
              execute.view{
                module = "initiative",
                view = "_list",
                params = {
                  issue = issue,
                  initiatives_selector = initiatives_selector,
                  highlight_string = highlight_string,
                  per_page = app.session.member_id and tonumber(app.session.member:get_setting_value("initiatives_preview_limit") or 3) or 3,
                  no_sort = true,
                  limit = app.session.member_id and tonumber(app.session.member:get_setting_value("initiatives_preview_limit") or 3) or 3
                }
              }
            end }
          end }
        end
      end }
    end
  }
end

filters.opened = true
filters.selector = issues_selector

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


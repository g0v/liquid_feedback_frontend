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


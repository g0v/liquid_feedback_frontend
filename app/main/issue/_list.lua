local issues_selector = param.get("issues_selector", "table")
local member = param.get("for_member", "table") or app.session.member
local for_member = param.get("for_member", "table")
local for_state = param.get("for_state")
local for_unit = param.get("for_unit", atom.boolean)
local for_area = param.get("for_area", atom.boolean)


if for_state == "open" then
  issues_selector:add_where("issue.closed ISNULL")
elseif for_state == "closed" then
  issues_selector:add_where("issue.closed NOTNULL")
end

if app.session.member_id then
  issues_selector
    :left_join("interest", "_interest", { "_interest.issue_id = issue.id AND _interest.member_id = ?", member.id } )
    :add_field("(_interest.member_id NOTNULL)", "is_interested")
  issues_selector
    :left_join("delegating_interest_snapshot", "_delegating_interest", { "_delegating_interest.issue_id = issue.id AND _delegating_interest.member_id = ? AND _delegating_interest.event = issue.latest_snapshot_event", member.id } )
    :add_field("_delegating_interest.delegate_member_ids[1]", "is_interested_by_delegation_to_member_id")
    :add_field("_delegating_interest.delegate_member_ids[array_upper(_delegating_interest.delegate_member_ids, 1)]", "is_interested_via_member_id")
    :add_field("array_length(_delegating_interest.delegate_member_ids, 1)", "delegation_chain_length")
end

ui.add_partial_param_names{
  "filter",
  "filter_open",
  "filter_voting",
  "filter_interest",
  "issue_list" 
}

local filters = execute.load_chunk{module="issue", chunk="_filters.lua", params = {
  member = member, for_member = for_member, state = for_state, for_unit = for_unit, for_area = for_area
}}

filters.content = function()
  ui.paginate{
    per_page = tonumber(param.get("per_page") or 25),
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
          elseif issue.is_interested_by_delegation_to_member_id then
            class = class .. " interested_by_delegation"
          end
          ui.container{ attr = { class = class }, content = function()

            ui.container{ attr = { class = "issue_info" }, content = function()
            
              if issue.is_interested then
                ui.tag{
                  tag = "div", attr = { class = "interest_by_delegation"},
                  content = function()
                    local text = "You are interested in this issue"
                    ui.image{ attr = { alt = text, title = text }, static = "icons/16/eye.png" }
                  end
                }
                
              elseif issue.is_interested_by_delegation_to_member_id then
                ui.tag{
                  tag = "div", attr = { class = "interest_by_delegation"},
                  content = function()
                    local member = Member:by_id(issue.is_interested_by_delegation_to_member_id)
                    local text = _"delegated to"
                    ui.image{
                      attr = { class = "delegation_arrow", alt = text, title = text },
                      static = "delegation_arrow_24_horizontal.png"
                    }
                    execute.view{
                      module = "member_image",
                      view = "_show",
                      params = {
                        member = member,
                        image_type = "avatar",
                        show_dummy = true,
                        class = "micro_avatar",
                        popup_text = member.name
                      }
                    }
                    if issue.is_interested_by_delegation_to_member_id ~= issue.is_interested_via_member_id then
                      if issue.delegation_chain_length > 2 then
                        local text = _"delegated to"
                        ui.image{
                          attr = { class = "delegation_arrow", alt = text, title = text },
                          static = "delegation_arrow_24_horizontal.png"
                        }
                        ui.tag{ content = "..." }
                      end
                    local text = _"delegated to"
                      ui.image{
                        attr = { class = "delegation_arrow", alt = text, title = text },
                        static = "delegation_arrow_24_horizontal.png"
                      }
                      local member = Member:by_id(issue.is_interested_via_member_id)
                      execute.view{
                        module = "member_image",
                        view = "_show",
                        params = {
                          member = member,
                          image_type = "avatar",
                          show_dummy = true,
                          class = "micro_avatar",
                          popup_text = member.name
                        }
                      }
                    end
                  end
                }
              end
            
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
                  ui.tag{ content = issue.policy.name }
                  slot.put(" &middot; ")
                  ui.tag{ content = issue.area.name }
                  slot.put(" &middot; ")
                  ui.tag{ content = issue.area.unit.name }

              end
              }
              ui.tag{
                attr = { class = "issue_policy_info" },
                tag = "div",
                content = function()
                
                  ui.tag{ attr = { class = "event_name" }, content = issue.state_name }

                  if issue.state_time_left then
                    slot.put(" &middot; ")
                    if issue.state_time_left:sub(1,1) == "-" then
                      if issue.state == "new" then
                        ui.tag{ content = _("Discussion starts soon") }
                      elseif issue.state == "discussion" then
                        ui.tag{ content = _("Verification starts soon") }
                      elseif issue.state == "frozen" then
                        ui.tag{ content = _("Voting starts soon") }
                      elseif issue.state == "voting" then
                        ui.tag{ content = _("Counting starts soon") }
                      end
                    else
                      ui.tag{ content = _("#{time_left} left", { time_left = issue.state_time_left:gsub("days", _"days"):gsub("day", _"day") }) }
                    end
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
                  limit = app.session.member_id and tonumber(app.session.member:get_setting_value("initiatives_preview_limit") or 3) or 3,
                  for_member = for_member
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

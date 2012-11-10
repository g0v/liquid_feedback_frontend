local members_selector = param.get("members_selector", "table")
members_selector:add_where("member.activated NOTNULL")

local initiative = param.get("initiative", "table")
local issue = param.get("issue", "table")
local trustee = param.get("trustee", "table")
local initiator = param.get("initiator", "table")
local for_votes = param.get("for_votes", atom.boolean)

local paginator_name = param.get("paginator_name")

if initiative or issue then
  if for_votes then
    members_selector:left_join("delegating_voter", "_member_list__delegating_voter", { "_member_list__delegating_voter.issue_id = issue.id AND _member_list__delegating_voter.member_id = ?", app.session.member_id })
    members_selector:add_field("_member_list__delegating_voter.delegate_member_id", "delegate_member_id")
  else
    members_selector:left_join("delegating_interest_snapshot", "_member_list__delegating_interest", { "_member_list__delegating_interest.event = issue.latest_snapshot_event AND _member_list__delegating_interest.issue_id = issue.id AND _member_list__delegating_interest.member_id = ?", app.session.member_id })
    members_selector:add_field("_member_list__delegating_interest.delegate_member_id", "delegate_member_id")
  end
end

ui.add_partial_param_names{ "member_list" }

local filter = { name = "member_list" }

filter[#filter+1] = {
  name = "newest",
  label = _"Newest",
  selector_modifier = function(selector) selector:add_order_by("activated DESC, id DESC") end
}
filter[#filter+1] = {
  name = "oldest",
  label = _"Oldest",
  selector_modifier = function(selector) selector:add_order_by("activated, id") end
}

filter[#filter+1] = {
  name = "name",
  label = _"A-Z",
  selector_modifier = function(selector) selector:add_order_by("name") end
}
filter[#filter+1] = {
  name = "name_desc",
  label = _"Z-A",
  selector_modifier = function(selector) selector:add_order_by("name DESC") end
}

local ui_filters = ui.filters
if (issue or initiative) and not trustee then
  ui_filters = function(args) args.content() end
  if for_votes then
      members_selector:add_order_by("voter_weight DESC, name, id")
  else
      members_selector:add_order_by("weight DESC, name, id")
  end
end

ui_filters{
  label = _"Change order",
  selector = members_selector,
  filter,
  content = function()

    slot.put("<br />")

    ui.paginate{
      name = paginator_name,
      anchor = paginator_name,
      selector = members_selector,
      per_page = 50,
      content = function()
        ui.container{
          attr = { class = "member_list" },
          content = function()

            local members = members_selector:exec()

            -- delegation page is not prepared for closed issues
            if issue and not issue.closed then

              -- serialize get-parameters
              local params = ''
              for key, value in pairs(param.get_all_cgi()) do
                params = params .. key .. "=" .. value .. "&"
              end

              for i, member in ipairs(members) do

                ui.container{
                  attr = { class = "contact_thumb" },
                  content = function()

                    execute.view{
                      module = "member",
                      view = "_show_thumb",
                      params = {
                        member = member,
                        initiative = initiative,
                        issue = issue,
                        trustee = trustee,
                        initiator = initiator
                      }
                    }

                    ui.container{
                      attr = { class = "contact_action" },
                      content = function()

                        -- link to delegation page
                        ui.link{
                          attr = { title = _"Show delegation list" },
                          module = "delegation",
                          view = "show",
                          params = {
                            issue_id  = issue.id,
                            member_id = member.id,
                            back_module = request.get_module(),
                            back_view = request.get_view(),
                            back_id = param.get_id_cgi(),
                            back_params = params
                          },
                          content = function()
                            ui.image{
                              attr = {
                                 alt = _"Show delegation list"
                              },
                              static = "icons/16/magnifier.png"
                            }
                          end
                        }

                      end
                    }

                  end
                }

              end -- for

            else -- if issue

              for i, member in ipairs(members) do
                execute.view{
                  module = "member",
                  view = "_show_thumb",
                  params = {
                    member = member,
                    initiative = initiative,
                    issue = issue,
                    trustee = trustee,
                    initiator = initiator
                  }
                }
              end

            end -- if issue

          end
        }
        slot.put('<br style="clear: left;" />')
      end
    }
  end
}

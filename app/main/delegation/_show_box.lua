function change_delegation(scope, area_id, issue, delegation, initiative_id)
  local image
  local text
  if scope == "global" and delegation then
    image = { static = "icons/16/table_go.png" }
    text = _"Change global delegation"
  elseif scope == "global" and not delegation then
    image = { static = "icons/16/table_go.png" }
    text = _"Set global delegation"
  elseif scope == "area" and delegation and delegation.area_id then
    image = { static = "icons/16/table_go.png" }
    text = _"Change area delegation"
  elseif scope == "area" and not (delegation and delegation.area_id) then
    image = { static = "icons/16/table_go.png" }
    text = _"Set area delegation"
  elseif scope == "issue" then
    if delegation and delegation.issue_id then
      image = { static = "icons/16/table_go.png" }
      text = _"Change issue delegation"
    elseif issue.state ~= "finished" and issue.state ~= "cancelled" then
      image = { static = "icons/16/table_go.png" }
      text = _"Set issue delegation"
    end
  end
  ui.container{
    attr = {
      class = "change_delegation",
    },
    content = function()
      ui.link{
        image  = image,
        text   = text,
        module = "delegation",
        view = "new",
        params = {
          issue_id = issue and issue.id or nil,
          initiative_id = initiative_id or nil,
          area_id = area_id
        },
      }
      if delegation then
        ui.link{
          image  = { static = "icons/16/delete.png" },
          text   = _"Revoke",
          module = "delegation",
          action = "update",
          params = { issue_id = delegation.issue_id, area_id = delegation.area_id, delete = true },
          routing = {
            default = {
              mode = "redirect",
              module = request.get_module(),
              view = request.get_view(),
              id = param.get_id_cgi(),
              params = param.get_all_cgi()
            }
          }
        }
      end
    end
  }
end

local delegation
local area_id
local issue_id
local initiative_id

local scope = "global"

if param.get("initiative_id", atom.integer) then
  initiative_id = param.get("initiative_id", atom.integer)
  issue_id = Initiative:by_id(initiative_id).issue_id
  scope = "issue"
end

if param.get("issue_id", atom.integer) then
  issue_id = param.get("issue_id", atom.integer)
  scope = "issue"
end

if param.get("area_id", atom.integer) then
  area_id = param.get("area_id", atom.integer)
  scope = "area"
end



local delegation
local issue

if issue_id then
  issue = Issue:by_id(issue_id)
  delegation = Delegation:by_pk(app.session.member.id, nil, issue_id)
  if not delegation then
    delegation = Delegation:by_pk(app.session.member.id, issue.area_id)
  end
elseif area_id then
  delegation = Delegation:by_pk(app.session.member.id, area_id)
end

if not delegation then
  delegation = Delegation:by_pk(app.session.member.id)
end


slot.select("actions", function()

  if delegation then
    ui.container{
      attr = { class = "delegation vote_info"},
      content = function()
        ui.container{
          attr = {
            title = _"Click for details",
            class = "head head_active",
            style = "cursor: pointer;",
            onclick = "document.getElementById('delegation_content').style.display = 'block';"
          },
          content = function()
            if delegation.trustee_id then
              ui.image{
                static = "icons/16/table_go.png"
              }
              if delegation.issue_id then
                slot.put(_"Issue delegation active")
              elseif delegation.area_id then
                slot.put(_"Area delegation active")
              else
                slot.put(_"Global delegation active")
              end
            else
              ui.image{
                static = "icons/16/table_go_crossed.png"
              }
              if delegation.issue_id then
                slot.put(_"Delegation turned off for issue")
              elseif delegation.area_id then
                slot.put(_"Delegation turned off for area")
              end
            end
            ui.image{
              static = "icons/16/dropdown.png"
            }
          end
        }
        ui.container{
          attr = { class = "content", id = "delegation_content" },
          content = function()
            ui.container{
              attr = {
                class = "close",
                style = "cursor: pointer;",
                onclick = "document.getElementById('delegation_content').style.display = 'none';"
              },
              content = function()
                ui.image{ static = "icons/16/cross.png" }
              end
            }
    
            local delegation_chain = Member:new_selector()
              :add_field("delegation_chain.*")
              :join("delegation_chain(" .. tostring(app.session.member.id) .. ", " .. tostring(unit_id or "NULL") .. ", " .. tostring(area_id or "NULL") .. ", " .. tostring(issue_id or "NULL") .. ")", "delegation_chain", "member.id = delegation_chain.member_id")
              :add_order_by("index")
              :exec()
    
            if not issue or (issue.state ~= "finished" and issue.state ~= "cancelled") then
              change_delegation(scope, area_id, issue, delegation, initiative_id)
            end

            for i, record in ipairs(delegation_chain) do
              local style
              local overridden = record.overridden
              if record.scope_in then
                ui.container{
                  attr = { class = "delegation_info" },
                  content = function()
                    if not overridden then
                      ui.image{
                        attr = { class = "delegation_arrow" },
                        static = "delegation_arrow_vertical.jpg"
                      }
                    else
                      ui.image{
                        attr = { class = "delegation_arrow delegation_arrow_overridden" },
                        static = "delegation_arrow_vertical.jpg"
                      }
                    end
                    ui.container{
                      attr = { class = "delegation_scope" .. (overridden and " delegation_scope_overridden" or "") },
                      content = function()
                        if record.scope_in == "global" then
                          slot.put(_"Global delegation")
                        elseif record.scope_in == "area" then
                          slot.put(_"Area delegation")
                        elseif record.scope_in == "issue" then
                          slot.put(_"Issue delegation")
                        end
                      end
                    }
                  end
                }
              end
              ui.container{
                attr = { class = overridden and "delegation_overridden" or "" },
                content = function()
                  execute.view{
                    module = "member",
                    view = "_show_thumb",
                    params = { member = record }
                  }
                end
              }
              if record.participation and not record.overridden then
                ui.container{
                  attr = { class = "delegation_participation" },
                  content = function()
                    slot.put(_"This member is participating, the rest of delegation chain is suspended while discussing")
                  end
                }
              end
              slot.put("<br style='clear: left'/>")
            end
          end
        }
      end
    }
  else
    change_delegation(scope, area_id, issue, nil, initiative_id)
  end
end)

slot.select("actions", function()

  ui.container{
    attr = { class = "delegation vote_info"},
    content = function()
    
      local delegation
      local area_id
      local issue_id
    
      local scope = "global"
    
      if param.get("initiative_id", atom.integer) then
        issue_id = Initiative:by_id(param.get("initiative_id", atom.integer)).issue_id
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
    
      if issue_id then
        delegation = Delegation:by_pk(app.session.member.id, nil, issue_id)
        if not delegation then
          local issue = Issue:by_id(issue_id)
          delegation = Delegation:by_pk(app.session.member.id, issue.area_id)
        end
      elseif area_id then
        delegation = Delegation:by_pk(app.session.member.id, area_id)
      end
    
      if not delegation then
        delegation = Delegation:by_pk(app.session.member.id)
      end
      if delegation then
        ui.container{
          attr = {
            title = _"Click for details",
            class = "head head_active",
            style = "cursor: pointer;",
            onclick = "document.getElementById('delegation_content').style.display = 'block';"
          },
          content = function()
            ui.image{
              static = "icons/16/error.png"
            }
            if delegation.issue_id then
              slot.put(_"Issue delegation active")
            elseif delegation.area_id then
              slot.put(_"Area wide delegation active")
            else
              slot.put(_"Global delegation active")
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
              :join("delegation_chain(" .. tostring(app.session.member.id) .. ", " .. tostring(area_id or "NULL") .. ", " .. tostring(issue_id or "NULL") .. ")", "delegation_chain", "member.id = delegation_chain.member_id")
              :add_order_by("index")
              :exec()
    
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
                    if i == 2 then
                      ui.link{
                        attr = { class = "revoke" },
                        content = function()
                          ui.image{ static = "icons/16/delete.png" }
                          slot.put(_"Revoke")
                        end,
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
                    slot.put("<br /><br />-----> Participation<br />")
                  end
                }
              end
              slot.put("<br style='clear: left'/>")
            end
          end
        }
      end
      ui.link{
        content = function()
          ui.image{ static = "icons/16/table_go.png" }
          if scope == "global" and delegation then
            slot.put(_"Change global delegation")
          elseif scope == "global" and not delegation then
            slot.put(_"Set global delegation")
          elseif scope == "area" and delegation and delegation.area_id then
            slot.put(_"Change area delegation")
          elseif scope == "area" and not (delegation and delegation.area_id) then
            slot.put(_"Set area delegation")
          elseif scope == "issue" and delegation and delegation.issue_id then
            slot.put(_"Change issue delegation")
          elseif scope == "issue" and not (delegation and delegation.issue_id) then
            slot.put(_"Set issue delegation")
          end
        end,
        module = "delegation",
        view = "new",
        params = {
          area_id = area_id,
          issue_id = issue_id 
        }
      }
    end
  }
end)

local delegations_selector = param.get("delegations_selector", "table")
local outgoing = param.get("outgoing", atom.boolean)
local incoming = param.get("incoming", atom.boolean)

-- display the scope
local function delegation_scope(delegation)
  ui.container{
    attr = { class = "delegations_scope" },
    content = function()
      if delegation.unit_id then
        ui.link{
          module = "unit",
          view = "show",
          id = delegation.unit_id,
          attr = { class = "unit_link" },
          text = _"Unit '#{name}'":gsub("#{name}", delegation.unit_name)
        }
      end
      if delegation.area_id then
        ui.link{
          module = "area",
          view = "show",
          id = delegation.area_id,
          attr = { class = "area_link" },
          text = _"Area '#{name}'":gsub("#{name}", delegation.area_name)
        }        
      end
      if delegation.issue_id then
        ui.link{
          module = "issue",
          view = "show",
          id = delegation.issue_id,
          attr = { class = "issue_link" },
          text = _"Issue ##{id}":gsub("#{id}", delegation.issue_id)
        }
      end
    end
  }
end

-- serialize get-parameters
local params = ''
for key, value in pairs(param.get_all_cgi()) do
  params = params .. key .. "=" .. value .. "&"
end

ui.paginate{
  selector = delegations_selector,
  content = function()
  
    local delegation_last_unit_id
    local delegation_last_area_id
    local delegation_last_issue_id
        
    for i, delegation in ipairs(delegations_selector:exec()) do
      
      -- scope
      if (incoming or outgoing) and (
        delegation.unit_id  ~= delegation_last_unit_id or 
        delegation.area_id  ~= delegation_last_area_id or 
        delegation.issue_id ~= delegation_last_issue_id
      ) then        
        delegation_scope(delegation)
        delegation_last_unit_id  = delegation.unit_id
        delegation_last_area_id  = delegation.area_id
        delegation_last_issue_id = delegation.issue_id       
      end
      
      ui.container{
        attr = { class = "delegations_list_row" },
        content = function()
      
          local delegation_chain = Member:new_selector()
            :add_field("delegation_chain.*")
            :join({ "delegation_chain(?,?,?,?,FALSE)", delegation.member_id, delegation.unit_id, delegation.area_id, delegation.issue_id }, "delegation_chain", "member.id = delegation_chain.member_id")
            :add_order_by("index")
            :limit(6) -- 1 = truster, 2-5 = displayed trustees, 6 = to see there are more
            :exec()
          
          for i, record in ipairs(delegation_chain) do
            local style
            local overridden = (not issue or issue.state ~= 'voting') and record.overridden
          
            -- display dots instead of the sixth trustee
            if i == 6 then
              break
            end
          
            -- arrow
            if i == 2 then
              ui.image{
                attr = {
                  class = "delegation_arrow" .. (overridden and " overridden" or ""),
                  alt = _"delegates to",
                  title = _"delegates to"
                },
                static = "delegation_arrow_24_horizontal.png"
              }
            end
               
            -- delegation 
            local class
            if overridden then
              class = "overridden"
            elseif record.participation then
              class = "highlighted"
            end
            ui.container{
              attr = { class = class },
              content = function()
                execute.view{
                  module = "member",
                  view = "_show_thumb",
                  params = { member = record }
                }
              end
            }
          
          end
          
          -- link to delegation page
          ui.link{
            attr = { title = _"Show more information" },
            module = "delegation",
            view = "show",
            params = {
              unit_id   = delegation.unit_id,
              area_id   = delegation.area_id,
              issue_id  = delegation.issue_id,
              member_id = delegation.member_id,
              back_module = request.get_module(),
              back_view = request.get_view(),
              back_id = param.get_id_cgi(),
              back_params = params
            },
            content = function()
              ui.image{
                attr = {
                   class = "more",
                   alt = _"Show more information"
                },
                static = "icons/16/magnifier.png"
              }
            end
          }             
    
          -- dots if not all trustees could be displayed
          if #delegation_chain > 5 then
            ui.container{
              attr = { class = "dots" },
              content = function()
                slot.put("<br />&nbsp;...")
              end
            }
          end
      
        end        
      }

    end

  end
}

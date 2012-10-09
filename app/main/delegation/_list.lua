local delegations_selector = param.get("delegations_selector", "table")
local outgoing = param.get("outgoing", atom.boolean)
local incoming = param.get("incoming", atom.boolean)

local function delegation_scope(delegation)
  ui.container{
    attr = { class = "delegations_scope" },
    content = function()
      if delegation.unit_id then
        ui.link{
          content = _"Unit '#{name}'":gsub("#{name}", delegation.unit_id),
          module = "unit",
          view = "show",
          id = delegation.unit_id
        }
      end
      if delegation.area_id then
        ui.link{
          content = _"Area '#{name}'":gsub("#{name}", delegation.area_name),
          module = "area",
          view = "show",
          id = delegation.area_id
        }
      end
      if delegation.issue_id then
        ui.link{
          content = _"Issue ##{id}":gsub("#{id}", delegation.issue_id),
          module = "issue",
          view = "show",
          id = delegation.issue_id
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
    for i, delegation in ipairs(delegations_selector:exec()) do
      
      if incoming or outgoing then
        delegation_scope(delegation)
      end
      
      local delegation_chain = Member:new_selector()
        :add_field("delegation_chain.*")
        :join({ "delegation_chain(?,?,?,?,FALSE)", delegation.member_id, delegation.unit_id, delegation.area_id, delegation.issue_id }, "delegation_chain", "member.id = delegation_chain.member_id")
        :add_order_by("index")
        :limit(6)
        :exec()
      
      for i, record in ipairs(delegation_chain) do
        local style
        local overridden = (not issue or issue.state ~= 'voting') and record.overridden
      
        -- show max. 4 delegates
        if i == 6 then
          break
        end
      
        -- arrow
        if i == 2 then
          ui.image{
            attr = {
              class = "delegations_arrow" .. (overridden and " delegation_arrow_overridden" or ""),
              alt = _"delegates to",
              title = _"delegates to"
            },
            static = "delegation_arrow_24_horizontal.png"
          }
        end
           
        -- delegation 
        local class = "delegations_list_row"
        if overridden then
          class = class .. " delegation_overridden"
        elseif record.participation then
          class = class .. " delegations_list_row_highlighted"
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
               class = "delegations_more",
               alt = _"Show more information"
            },
            static = "icons/16/magnifier.png"
          }
        end
      }             

      if #delegation_chain > 5 then
        ui.container{
          attr = { class = "delegations_dots" },
          content = function()
            slot.put("<br />&nbsp;...")
          end
        }
      end
      
      slot.put("<br style='clear: left;' />")
    
    end

  end
}

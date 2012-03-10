local member = param.get("member", "table")
local units = member.units_with_voting_right

for i, unit in ipairs(units) do
  local trustee_member = Member:new_selector()
    :join("delegation", nil, { "delegation.unit_id = ? AND delegation.truster_id = ?", unit.id, member.id })
    :optional_object_mode()
    :exec()
  
  local areas_selector = Area:new_selector()
    :join("membership", nil, { "membership.area_id = area.id AND membership.member_id = ?", member.id })
    :add_where{ "area.unit_id = ?", unit.id }
    :add_order_by("area.member_weight DESC")
  
  local area_count = areas_selector:count()
  
  ui.container{ attr = { class = "member_area_list" }, content = function()
    ui.container{ attr = { class = "unit_head" }, content = function()
      ui.link{
        text = unit.name,
        module = "unit", view = "show", id = unit.id
      }

      if trustee_member then
        local text = _("Unit delegated to '#{name}'", { name = trustee_member.name })
        ui.image{
          attr = { class = "delegation_arrow", alt = text, title = text },
          static = "delegation_arrow_24_horizontal.png"
        }
        execute.view{
          module = "member_image",
          view = "_show",
          params = {
            member = trustee_member,
            image_type = "avatar",
            show_dummy = true,
            class = "micro_avatar",
            popup_text = text
          }
        }
      end
    end }

    if area_count > 0 then
      execute.view{
        module = "area", view = "_list",
        params = { areas_selector = areas_selector, hide_membership = true }
      }
    else
      ui.container{ attr = { class = "voting_priv_info" }, content = _"You have voting privileges for this unit, but you are not member of any of its areas." }
    end
    ui.container{ content = function()
      ui.link{ content = _"Show all areas of unit", module = "unit", view = "show", id = unit.id }
    end }
          
  end }

end

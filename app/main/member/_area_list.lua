local member = param.get("member", "table")
local for_member = param.get("for_member", atom.boolean)

local units = member.units_with_voting_right

for i, unit in ipairs(units) do
  local trustee_member = Member:new_selector()
    :join("delegation", nil, { "delegation.scope = 'unit' AND delegation.unit_id = ? AND delegation.trustee_id = member.id AND delegation.truster_id = ?", unit.id, member.id })
    :optional_object_mode()
    :exec()
  
  local areas_selector = Area:new_selector()
    :join("membership", nil, { "membership.area_id = area.id AND membership.member_id = ?", member.id })
    :add_where{ "area.unit_id = ?", unit.id }
    :add_where{ "area.active" }
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
      if for_member then
        ui.container{ attr = { class = "voting_priv_info" }, content = _"This member has voting privileges for this unit, but you ist not member of any of its areas." }
      else
        ui.container{ attr = { class = "voting_priv_info" }, content = _"You have voting privileges for this unit, but you are not member of any of its areas." }
      end
    end
    local max_area_count = Area:new_selector()
      :add_where{ "area.unit_id = ?", unit.id }
      :add_where{ "area.active" }
      :count()
    local more_area_count = max_area_count - area_count
    local delegated_count = Area:new_selector()
      :add_where{ "area.unit_id = ?", unit.id }
      :add_where{ "area.active" }
      :left_join("membership", nil, { "membership.area_id = area.id AND membership.member_id = ?", member.id } )
      :add_where{ "membership.member_id ISNULL" }
      :join("delegation", nil, { "delegation.area_id = area.id AND delegation.truster_id = ?", member.id } )
      :count()
    if more_area_count > 0 then
      slot.put("<br />")
      ui.container{ attr = { class = "more_areas" }, content = function()
        ui.link{ content = _("#{count} more areas in this unit, #{delegated_count} of them are delegated", { count = more_area_count, delegated_count = delegated_count }), module = "unit", view = "show", id = unit.id }
      end }
    end
  end }

end

local member = param.get("member", "table")
local for_member = param.get("for_member", atom.boolean)
local filter_unit = param.get_all_cgi()["filter_unit"] or "personal"


execute.view{
  module = "index", view = "_notifications"
}

    
ui.container{ attr = { class = "ui_filter_head" }, content = function()

  ui.link{
    attr = { class = filter_unit == "personal" and "ui_tabs_link active" or nil },
    text = _"My units and areas",
    module = "index", view = "index", params = { filter_unit = "personal" }
  }
  
  slot.put(" ")

  ui.link{
    attr = { class = filter_unit == "global" and "active" or nil },
    text = _"All units",
    module = "index", view = "index", params = { filter_unit = "global" }
  }
end }

slot.put("<br />")


if filter_unit == "global" then
  execute.view{ module = "unit", view = "_list" }
  return
end

local units = Unit:new_selector():exec()

for i, unit in ipairs(units) do
  if not member:has_voting_right_for_unit_id(unit.id) then
    break
  end
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
    elseif member:has_voting_right_for_unit_id(unit.id) then
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



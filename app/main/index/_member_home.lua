local member = param.get("member", "table")
local for_member = param.get("for_member", atom.boolean)
local filter_unit = param.get_all_cgi()["filter_unit"] or "my_areas"

if not for_member then
  execute.view{
    module = "index", view = "_notifications"
  }
    
  ui.container{ attr = { class = "ui_filter" }, content = function()
    ui.container{ attr = { class = "ui_filter_head" }, content = function()

      ui.link{
        attr = { class = filter_unit == "my_areas" and "ui_tabs_link active" or nil },
        text = _"My areas",
        module = "index", view = "index", params = { filter_unit = "my_areas" }
      }
      
      slot.put(" ")

      ui.link{
        attr = { class = filter_unit == "my_units" and "ui_tabs_link active" or nil },
        text = _"All areas in my units",
        module = "index", view = "index", params = { filter_unit = "my_units" }
      }
      
      slot.put(" ")

      ui.link{
        attr = { class = filter_unit == "global" and "active" or nil },
        text = _"All units",
        module = "index", view = "index", params = { filter_unit = "global" }
      }
    end }
  end }
end

  slot.put("<br />")

if not for_member then
  if filter_unit == "global" then
    execute.view{ module = "unit", view = "_list" }
    return
  end

end

local units = Unit:new_selector():add_order_by("name"):exec()

if member then
  units:load_delegation_info_once_for_member_id(member.id)
end

for i, unit in ipairs(units) do
  if member:has_voting_right_for_unit_id(unit.id) then
   
    local areas_selector = Area:new_selector()
      :reset_fields()
      :add_field("area.id", nil, { "grouped" })
      :add_field("area.name", nil, { "grouped" })
      :add_field("member_weight", nil, { "grouped" })
      :add_field("direct_member_count", nil, { "grouped" })
      :add_field("(SELECT COUNT(*) FROM issue WHERE issue.area_id = area.id AND issue.accepted ISNULL AND issue.closed ISNULL)", "issues_new_count")
      :add_field("(SELECT COUNT(*) FROM issue WHERE issue.area_id = area.id AND issue.accepted NOTNULL AND issue.half_frozen ISNULL AND issue.closed ISNULL)", "issues_discussion_count")
      :add_field("(SELECT COUNT(*) FROM issue WHERE issue.area_id = area.id AND issue.half_frozen NOTNULL AND issue.fully_frozen ISNULL AND issue.closed ISNULL)", "issues_frozen_count")
      :add_field("(SELECT COUNT(*) FROM issue WHERE issue.area_id = area.id AND issue.fully_frozen NOTNULL AND issue.closed ISNULL)", "issues_voting_count")
      :add_field("(SELECT COUNT(*) FROM issue WHERE issue.area_id = area.id AND issue.fully_frozen NOTNULL AND issue.closed NOTNULL)", "issues_finished_count")
      :add_field("(SELECT COUNT(*) FROM issue WHERE issue.area_id = area.id AND issue.fully_frozen ISNULL AND issue.closed NOTNULL)", "issues_cancelled_count")
      :add_where{ "area.unit_id = ?", unit.id }
      :add_where{ "area.active" }
      :add_order_by("area.name")

    if filter_unit == "my_areas" then
      areas_selector:join("membership", nil, { "membership.area_id = area.id AND membership.member_id = ?", member.id })
    end
    
    local area_count = areas_selector:count()
    
    ui.container{ attr = { class = "area_list" }, content = function()
      ui.container{ attr = { class = "unit_head" }, content = function()
        ui.link{
          text = unit.name,
          module = "unit", view = "show", id = unit.id
        }

        execute.view{ module = "delegation", view = "_info", params = { unit = unit } }
      end }

      if area_count > 0 then
        local areas = areas_selector:exec()
        for i, area in ipairs(areas) do
          execute.view{
            module = "area", view = "_list_entry", params = {
              area = area
            }
          }
        end
      elseif member:has_voting_right_for_unit_id(unit.id) then
        ui.container{ attr = { class = "area" }, content = function()
          ui.container{ attr = { class = "content" }, content = function()
            slot.put("<br />")
            if for_member then
              ui.tag{ content = _"This member has voting privileges for this unit, but you ist not member of any of its areas." }
            else
              ui.tag{ content = _"You have voting privileges for this unit, but you are not member of any of its areas." }
            end
          end }
        end }
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
        :add_where{ "delegation.trustee_id NOTNULL" }
        :count()
      if more_area_count > 0 then
        ui.container{ attr = { class = "area" }, content = function()
          ui.container{ attr = { class = "content" }, content = function()
            slot.put("<br />")
            ui.link{ content = _("#{count} more areas in this unit, #{delegated_count} of them have an area delegation set", { count = more_area_count, delegated_count = delegated_count }), module = "unit", view = "show", id = unit.id }
          end }
        end }
      end
      slot.put("<br />")
      slot.put("<br />")
    end }
  end
end



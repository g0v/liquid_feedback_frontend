-- displays the head bar of a unit


local unit = param.get("unit", "table")
local member = param.get("member", "table")

local show_content = param.get("show_content", atom.boolean)

if app.session.member_id then
  unit:load_delegation_info_once_for_member_id(app.session.member_id)
end

ui.container{ attr = { class = "unit_head" }, content = function()

  -- unit title
  ui.container{ attr = { class = "title left" }, content = function()
    ui.link{
      module = "unit", view = "show", id = unit.id,
      attr = { class = "unit_name" }, content = unit.name
    }
  end }

  -- unit delegation
  execute.view{ module = "delegation", view = "_info", params = { unit = unit, member = member } }

  -- voting rights
  if show_content and member and member:has_voting_right_for_unit_id(unit.id) then
    ui.container{ attr = { class = "content left clear_left" }, content = function()
      if app.session.member_id == member.id then
        ui.tag{ content = _"You have voting privileges for this unit." }
      else
        ui.tag{ content = _"Member has voting privileges for this unit." }
      end
    end }
  end

  slot.put('<div class="clearfix"></div>')

end }

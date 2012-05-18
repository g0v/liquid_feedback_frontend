local unit = param.get("unit", "table")

ui.container{ attr = { class = "unit_head" }, content = function()

  execute.view{ module = "delegation", view = "_info", params = { unit = unit } }

  ui.container{ attr = { class = "title" }, content = function()
    if not config.single_unit_id then
      ui.link{ 
        module = "unit", view = "show", id = unit.id,
        attr = { class = "unit_name" }, content = unit.name
      }
    else
      ui.link{ 
        module = "unit", view = "show", id = unit.id,
        attr = { class = "unit_name" }, content = config.app_title
      }
    end
  end }

  ui.container{ attr = { class = "content" }, content = function()

    if app.session.member_id and app.session.member:has_voting_right_for_unit_id(unit.id) then
      ui.tag{ content = _"You have voting privileges for this unit" }
    end
  end }
  
end }

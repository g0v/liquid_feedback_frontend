local unit = param.get("unit", "table")

slot.select("head", function()

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
        
      ui.tag{ content = "1234 Stimmberechtigte" }
        
    end }
    
  end }

end )
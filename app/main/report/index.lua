function link_area(area)
  ui.link{
    external = "",
    attr = {
      onclick =
        "openEl('area_" .. tostring(area.id) .. "');" ..
        "return(false);"
    },
    content = function()
      ui.heading{
        content = area.name
      }
    end
  }
end

slot.set_layout("report")

slot.put("<br />")

ui.container{
  attr = {
    class = "nav",
    style = "text-align: center;"
  },
  content = function()


    ui.container{
      attr = { 
        class = "left",
      },
      content = function()
        ui.link{
          external = "",
          attr = {
            onclick = "undo(); return(false);"
          },
          content = function()
            ui.image{ static = "icons/16/cancel.png" }
            slot.put(" ")
            slot.put(_"Back")
          end
        }
      end
    }

    ui.form{
      attr = {
        style = "float: right;",
        onsubmit = "openElDirect(); return(false);"
      },
      content = function()
        slot.put("#")
        ui.tag{
          tag = "input",
          attr = {
            id = "input_issue",
            type = "text",
            style = "width: 4em;"
          }
        }
        slot.put(".")
        ui.tag{
          tag = "input",
          attr = {
            id = "input_initiative",
            type = "text",
            style = "width: 4em;"
          }
        }
        slot.put(" ")
        ui.tag{
          tag = "input",
          attr = {
            type = "submit",
            value = "OK",
          }
        }
      end
    }


    ui.link{
      external = "",
      attr = {
        onclick = "openPrevIssue(); return(false);"
      },
      content = function()
        ui.image{ static = "icons/16/resultset_previous_double.png" }
        slot.put(" ")
        slot.put(_"Previous issue")
      end
    }

    ui.link{
      external = "",
      attr = {
        onclick = "openPrevInitiative(); return(false);"
      },
      content = function()
        ui.image{ static = "icons/16/resultset_previous.png" }
        slot.put(" ")
        slot.put(_"Previous initiative")
      end
    }

    ui.link{
      external = "",
      attr = {
        onclick = "openParent(); return(false);"
      },
      content = function()
        ui.image{ static = "icons/16/go_up.png" }
        slot.put(" ")
        slot.put(_"Go up")
      end
    }

    ui.link{
      external = "",
      attr = {
        onclick = "openNextInitiative(); return(false);"
      },
      content = function()
        ui.image{ static = "icons/16/resultset_next.png" }
        slot.put(" ")
        slot.put(_"Next initiative")
      end
    }

    ui.link{
      external = "",
      attr = {
        onclick = "openNextIssue(); return(false);"
      },
      content = function()
        ui.image{ static = "icons/16/resultset_next_double.png" }
        slot.put(" ")
        slot.put(_"Next issue")
      end
    }
  end
}

slot.put("<br />")

local areas = Area:new_selector():add_order_by("name"):exec()


ui.container{
  attr = { id = "areas" },
  content = function()
    for i, area in ipairs(areas) do
      link_area(area)
    end
    slot.put("<br /><br />")
    slot.put(_"This report can be saved (use 'save complete website') and used offline.")  end
}

ui.script{ script = "openEl('areas')" }

for i, area in ipairs(areas) do
  execute.view{
    module = "report",
    view = "area",
    params = { area = area }
  }
end


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
        attr = { style = "background-color: #000; color: #fff;" },
        content = area.name
      }
    end
  }
end

slot.set_layout("report")

ui.form{
  attr = {
    style = " float: right;",
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
    onclick = "undo(); return(false);"
  },
  text = _"Back"
}

slot.put(" ")

ui.link{
  external = "",
  text = _"Areas"
}

slot.put(" ")

ui.link{
  external = "",
  attr = {
    onclick = "openPrevIssue(); return(false);"
  },
  text = "<< " .. _"Previous issue"
}

slot.put(" ")

ui.link{
  external = "",
  attr = {
    onclick = "openPrevInitiative(); return(false);"
  },
  text = "< " .. _"Previous initiative"
}

slot.put(" ")

ui.link{
  external = "",
  attr = {
    onclick = "openNextInitiative(); return(false);"
  },
  text = _"Next initiative" .. " >"
}

slot.put(" ")

ui.link{
  external = "",
  attr = {
    onclick = "openNextIssue(); return(false);"
  },
  text = _"Next issue" .. " >>"
}

local areas = Area:new_selector():exec()


ui.container{
  attr = { id = "areas" },
  content = function()
    for i, area in ipairs(areas) do
      link_area(area)
    end
  end
}

ui.script{ script = "openEl('areas')" }

for i, area in ipairs(areas) do
  execute.view{
    module = "report",
    view = "area",
    params = { area = area }
  }
end
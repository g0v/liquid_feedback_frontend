slot.put_into("title", _"Unit list")

util.help("unit.list", _"Unit list")

slot.put("<br />")

ui.container{ attr = { class = "box" }, content = function()
  execute.view{ module = "unit", view = "_list" }
end }

slot.put("<br />")


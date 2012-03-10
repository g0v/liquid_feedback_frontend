slot.put_into("title", _"Unit list")

util.help("unit.list", _"Unit list")

ui.container{ attr = { class = "box" }, content = function()
  execute.view{ module = "unit", view = "_list" }
end }
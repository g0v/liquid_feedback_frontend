local initiatives_selector = param.get("initiatives_selector", "table")
if initiatives_selector:count() > 0 then
  ui.container{
    attr = { style = "font-weight: bold;" },
    content = _"Open initiatives you are supporting which has been updated their draft:"
  }

  execute.view{
    module = "initiative",
    view = "_list",
    params = { initiatives_selector = initiatives_selector }
  }
end
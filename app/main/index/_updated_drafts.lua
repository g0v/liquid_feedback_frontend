local initiatives_selector = param.get("initiatives_selector", "table")
if initiatives_selector:count() > 0 then
  ui.container{
    attr = { class = "heading" },
    content = _"Open initiatives you are supporting which has been updated their draft:"
  }
  
  slot.put("<br />")

  execute.view{
    module = "initiative",
    view = "_list",
    params = { initiatives_selector = initiatives_selector }
  }
end
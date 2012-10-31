local draft = param.get("draft", "table")
local source = param.get("source", atom.boolean)

if source then

  ui.tag{
    tag = "pre",
    attr = { class = "diff" },
    content = draft.content
  }

else

  ui.container{ attr = { class = "initiative_head" }, content = function()

    ui.container{
      attr = { class = "draft_content wiki" },
      content = function()
        slot.put(draft:get_content("html"))
      end
    }

  end }

end


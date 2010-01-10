local draft = param.get("draft", "table")

ui.form{
  attr = { class = "vertical" },
  record = draft,
  readonly = true,
  content = function()

    ui.field.text{ label = _"Last author", name = "author_name" }
    ui.field.timestamp{ label = _"Created at", name = "created" }
    ui.container{
      attr = { class = "draft_content wiki" },
      content = function()
        slot.put(format.wiki_text(draft.content, draft.formatting_engine))
      end
    }
  end
}

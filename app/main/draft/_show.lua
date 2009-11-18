local draft = param.get("draft", "table")

ui.form{
  attr = { class = "vertical" },
  record = draft,
  readonly = true,
  content = function()

    ui.field.text{ label = _"Initiative", value = draft.initiative.name }
    ui.field.text{ label = _"Author", name = "author_name" }
    ui.field.text{ label = _"Content", name = "content" }

  end
}

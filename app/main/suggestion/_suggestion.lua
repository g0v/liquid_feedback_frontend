local suggestion = param.get("suggestion", "table")

ui.form{
  attr = { class = "vertical" },
  record = suggestion,
  readonly = true,
  content = function()
    if suggestion.author then 
      suggestion.author:ui_field_text{label=_"Author"} 
    end
    ui.field.text{ label = _"Title",        name = "name" }
    ui.container{
      attr = { class = "suggestion_content wiki" },
      content = function()
        slot.put(encode.html_newlines(encode.html(suggestion.description)))
      end
    }
  end
}
execute.view{
  module = "suggestion",
  view = "_list",
  params = {
    suggestions_selector = Suggestion:new_selector():add_where{ "id = ?", suggestion.id },
    initiative = suggestion.initiative,
    show_name = false,
    show_filter = false
  }
}

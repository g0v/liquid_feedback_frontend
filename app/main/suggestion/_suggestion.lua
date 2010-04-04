local suggestion = param.get("suggestion", "table")

ui.form{
  attr = { class = "vertical" },
  record = suggestion,
  readonly = true,
  content = function()
    if app.session.member_id or config.public_access == "pseudonym" then
      ui.field.text{ label = _"Author",      value = suggestion.author.name }
    else
      ui.field.text{ label = _"Author",      value = _"[not displayed public]" }
    end
    ui.field.text{ label = _"Title",        name = "name" }
    ui.container{
      attr = { class = "suggestion_content wiki" },
      content = function()
        ui.tag{
          tag = "p",
          content = suggestion.description
        }
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

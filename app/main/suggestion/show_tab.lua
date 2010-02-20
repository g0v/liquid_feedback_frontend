local suggestion = param.get("suggestion", "table") or Suggestion:by_id(param.get("suggestion_id"))

ui.tabs{
  module = "suggestion",
  view = "show_tab",
  static_params = {
    suggestion_id = suggestion.id
  },
  {
    name = "description",
    label = _"Suggestion",
    module = "suggestion",
    view = "_suggestion",
    params = {
      suggestion = suggestion
    }
  },
  {
    name = "opinions",
    label = _"Opinions",
    module = "suggestion",
    view = "_opinions",
    params = {
      suggestion = suggestion
    }
  }
}


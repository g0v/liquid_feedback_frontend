local suggestions_selector = param.get("suggestions_selector", "table")

ui.paginate{
  selector = suggestions_selector,
  content = function()
    ui.list{
      attr = { style = "table-layout: fixed;" },
      records = suggestions_selector:exec(),
      columns = {
        {
          label = _"Name",
          content = function(record)
            ui.link{
              text = record.name,
              module = "suggestion",
              view = "show",
              id = record.id
            }
          end
        },
        {
          label = _"Support",
          content = function(record)
            if record.minus2_unfulfilled_count then
              local max_value = record.initiative.issue.population
              ui.bargraph{
                max_value = max_value,
                width = 100,
                bars = {
                  { color = "#ddd", value = max_value - record.minus2_unfulfilled_count - record.minus1_unfulfilled_count - record.minus2_fulfilled_count - record.minus1_fulfilled_count },
                  { color = "#f88", value = record.minus1_unfulfilled_count + record.minus1_fulfilled_count },
                  { color = "#a00", value = record.minus2_unfulfilled_count + record.minus2_fulfilled_count },
                  { color = "#0a0", value = record.plus2_unfulfilled_count + record.plus2_fulfilled_count },
                  { color = "#8f8", value = record.plus1_unfulfilled_count + record.plus1_fulfilled_count },
                  { color = "#ddd", value = max_value - record.plus1_unfulfilled_count - record.plus2_unfulfilled_count - record.plus1_fulfilled_count - record.plus2_fulfilled_count },
                }
              }
            end
          end
        },
        {
          content = function(record)
            local degree
            local opinion = Opinion:by_pk(app.session.member.id, record.id)
            if opinion then
              degree = opinion.degree
            end
            ui.link{
              attr = { class = "action" .. (degree == -2 and " active_red2" or "") },
              text = _"must not",
              module = "opinion",
              action = "update",
              routing = { default = { mode = "redirect", module = request.get_module(), view = request.get_view(), id = param.get_id_cgi(), params = param.get_all_cgi() } },
              params = {
                suggestion_id = record.id,
                degree = -2
              }
            }
            ui.link{
              attr = { class = "action" .. (degree == -1 and " active_red1" or "") },
              text = _"should not",
              module = "opinion",
              action = "update",
              routing = { default = { mode = "redirect", module = request.get_module(), view = request.get_view(), id = param.get_id_cgi(), params = param.get_all_cgi() } },
              params = {
                suggestion_id = record.id,
                degree = -1
              }
            }
            ui.link{
              attr = { class = "action" .. (degree == nil and " active" or "") },
              text = _"neutral",
              module = "opinion",
              action = "update",
              routing = { default = { mode = "redirect", module = request.get_module(), view = request.get_view(), id = param.get_id_cgi(), params = param.get_all_cgi() } },
              params = {
                suggestion_id = record.id,
                delete = true
              }
            }
            ui.link{
              attr = { class = "action" .. (degree == 1 and " active_green1" or "") },
              text = _"should",
              module = "opinion",
              action = "update",
              routing = { default = { mode = "redirect", module = request.get_module(), view = request.get_view(), id = param.get_id_cgi(), params = param.get_all_cgi() } },
              params = {
                suggestion_id = record.id,
                degree = 1
              }
            }
            ui.link{
              attr = { class = "action" .. (degree == 2 and " active_green2" or "") },
              text = _"must",
              module = "opinion",
              action = "update",
              routing = { default = { mode = "redirect", module = request.get_module(), view = request.get_view(), id = param.get_id_cgi(), params = param.get_all_cgi() } },
              params = {
                suggestion_id = record.id,
                degree = 2
              }
            }
          end
        },
        {
          label = _"Suggestion currently not implemented",
          label_attr = { style = "width: 101px;" },
          content = function(record)
            if record.minus2_unfulfilled_count then
              local max_value = record.initiative.issue.population
              ui.bargraph{
                max_value = max_value,
                width = 100,
                bars = {
                  { color = "#ddd", value = max_value - record.minus2_unfulfilled_count - record.minus1_unfulfilled_count },
                  { color = "#f88", value = record.minus1_unfulfilled_count },
                  { color = "#a00", value = record.minus2_unfulfilled_count },
                  { color = "#0a0", value = record.plus2_unfulfilled_count },
                  { color = "#8f8", value = record.plus1_unfulfilled_count },
                  { color = "#ddd", value = max_value - record.plus1_unfulfilled_count - record.plus2_unfulfilled_count },
                }
              }
            end
          end
        },
        {
          label = _"Suggestion currently implemented",
          label_attr = { style = "width: 101px;" },
          content = function(record)
            if record.minus2_fulfilled_count then
              local max_value = record.initiative.issue.population
              ui.bargraph{
                max_value = max_value,
                width = 100,
                bars = {
                  { color = "#ddd", value = max_value - record.minus2_fulfilled_count - record.minus1_fulfilled_count },
                  { color = "#f88", value = record.minus1_fulfilled_count },
                  { color = "#a00", value = record.minus2_fulfilled_count },
                  { color = "#0a0", value = record.plus2_fulfilled_count },
                  { color = "#8f8", value = record.plus1_fulfilled_count },
                  { color = "#ddd", value = max_value - record.plus1_fulfilled_count - record.plus2_fulfilled_count },
                }
              }
            end
          end
        },
        {
          content = function(record)
            local degree
            local opinion = Opinion:by_pk(app.session.member.id, record.id)
            if opinion then
              degree = opinion.degree
            end
            if opinion then
              if not opinion.fulfilled then
                ui.image{ static = "icons/16/cross.png" }
                ui.link{
                  attr = { class = "action" },
                  text = _"set implented",
                  module = "opinion",
                  action = "update",
                  routing = { default = { mode = "redirect", module = request.get_module(), view = request.get_view(), id = param.get_id_cgi(), params = param.get_all_cgi() } },
                  params = {
                    suggestion_id = record.id,
                    fulfilled = true
                  }
                }
              else
                ui.image{ static = "icons/16/tick.png" }
                ui.link{
                  attr = { class = "action" },
                  text = _"remove implemented",
                  module = "opinion",
                  action = "update",
                  routing = { default = { mode = "redirect", module = request.get_module(), view = request.get_view(), id = param.get_id_cgi(), params = param.get_all_cgi() } },
                  params = {
                    suggestion_id = record.id,
                    fulfilled = false
                  }
                }
              end
            end
          end
        },
      }
    }
  end
}

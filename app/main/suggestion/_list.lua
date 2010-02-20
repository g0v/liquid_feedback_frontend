
local initiative = param.get("initiative", "table")
local suggestions_selector = param.get("suggestions_selector", "table")
local tab_id = param.get("tab_id")
local show_name = param.get("show_name", atom.boolean)
if show_name == nil then
  show_name = true
end
local show_filter = param.get("show_filter", atom.boolean)
if show_filter == nil then
  show_filter = true
end

local partial = {
  routing = {
    default = {
      mode = "redirect",
      module = "initiative",
      view = "show_tab",
      params = {
        initiative_id = initiative.id,
        tab = "suggestions",
        tab_id = tab_id
      },
    }
  }
}

local ui_filters = ui.filters
if not show_filter then
  ui_filters = function(args) args.content() end
end

ui_filters{
  label = _"Show filter",
  selector = suggestions_selector,
  {
    label = _"Order by",
    {
      name = "plus_unfulfilled",
      label = _"requested",
      selector_modifier = function(selector) selector:add_order_by("plus2_unfulfilled_count + plus1_unfulfilled_count DESC, id") end
    },
    {
      name = "plus2",
      label = _"must",
      selector_modifier = function(selector) selector:add_order_by("plus2_unfulfilled_count + plus2_fulfilled_count DESC, id") end
    },
    {
      name = "plus",
      label = _"must/should",
      selector_modifier = function(selector) selector:add_order_by("plus2_unfulfilled_count + plus1_unfulfilled_count + plus2_fulfilled_count + plus1_fulfilled_count DESC, id") end
    },
    {
      name = "minus",
      label = _"must/should not",
      selector_modifier = function(selector) selector:add_order_by("minus2_unfulfilled_count + minus1_unfulfilled_count + minus2_fulfilled_count + minus1_fulfilled_count DESC, id") end
    },
    {
      name = "minus2",
      label = _"must not",
      selector_modifier = function(selector) selector:add_order_by("minus2_unfulfilled_count + minus2_fulfilled_count DESC, id") end
    }
  },
  content = function()
    ui.paginate{
      selector = suggestions_selector,
      content = function()
        ui.list{
          attr = { style = "table-layout: fixed;" },
          records = suggestions_selector:exec(),
          columns = {
            {
              label = show_name and _"Suggestion" or nil,
              content = function(record)
                if show_name then
                  ui.link{
                    text = record.name,
                    module = "suggestion",
                    view = "show",
                    id = record.id
                  }
                end
              end
            },
            {
              label = _"Collective opinion",
              label_attr = { style = "width: 101px;" },
              content = function(record)
                if record.minus2_unfulfilled_count then
                  local max_value = record.initiative.issue.population
                  ui.bargraph{
                    max_value = max_value,
                    width = 50,
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
              label = _"My opinion",
              content = function(record)
                local degree
                local opinion = Opinion:by_pk(app.session.member.id, record.id)
                if opinion then
                  degree = opinion.degree
                end
                ui.container{
                  attr = { class = "suggestion_my_opinion" },
                  content = function()
                    if initiative.issue.state == "voting" or initiative.issue.state == "closed" then
                      ui.tag{
                        tag = "span",
                        attr = { class = "action" .. (degree == -2 and " active_red2" or "") },
                        content = _"must not"
                      }
                      ui.tag{
                        tag = "span",
                        attr = { class = "action" .. (degree == -1 and " active_red1" or "") },
                        content = _"should not"
                      }
                      ui.tag{
                        tag = "span",
                        attr = { class = "action" .. (degree == nil and " active" or "") },
                        content = _"neutral"
                      }
                      ui.tag{
                        tag = "span",
                        attr = { class = "action" .. (degree == 1 and " active_green1" or "") },
                        content = _"should"
                      }
                      ui.tag{
                        tag = "span",
                        attr = { class = "action" .. (degree == 2 and " active_green2" or "") },
                        content = _"must"
                      }
                    else
                      ui.link{
                        attr = { class = "action" .. (degree == -2 and " active_red2" or "") },
                        text = _"must not",
                        module = "opinion",
                        action = "update",
                        routing = { default = { mode = "redirect", module = request.get_module(), view = request.get_view(), id = param.get_id_cgi(), params = param.get_all_cgi() } },
                        params = {
                          suggestion_id = record.id,
                          degree = -2
                        },
                        partial = partial
                      }
                      slot.put(" ")
                      ui.link{
                        attr = { class = "action" .. (degree == -1 and " active_red1" or "") },
                        text = _"should not",
                        module = "opinion",
                        action = "update",
                        routing = { default = { mode = "redirect", module = request.get_module(), view = request.get_view(), id = param.get_id_cgi(), params = param.get_all_cgi() } },
                        params = {
                          suggestion_id = record.id,
                          degree = -1
                        },
                        partial = partial
                      }
                      slot.put(" ")
                      ui.link{
                        attr = { class = "action" .. (degree == nil and " active" or "") },
                        text = _"neutral",
                        module = "opinion",
                        action = "update",
                        routing = { default = { mode = "redirect", module = request.get_module(), view = request.get_view(), id = param.get_id_cgi(), params = param.get_all_cgi() } },
                        params = {
                          suggestion_id = record.id,
                          delete = true
                        },
                        partial = partial
                      }
                      slot.put(" ")
                      ui.link{
                        attr = { class = "action" .. (degree == 1 and " active_green1" or "") },
                        text = _"should",
                        module = "opinion",
                        action = "update",
                        routing = { default = { mode = "redirect", module = request.get_module(), view = request.get_view(), id = param.get_id_cgi(), params = param.get_all_cgi() } },
                        params = {
                          suggestion_id = record.id,
                          degree = 1
                        },
                        partial = partial
                      }
                      slot.put(" ")
                      ui.link{
                        attr = { class = "action" .. (degree == 2 and " active_green2" or "") },
                        text = _"must",
                        module = "opinion",
                        action = "update",
                        routing = { default = { mode = "redirect", module = request.get_module(), view = request.get_view(), id = param.get_id_cgi(), params = param.get_all_cgi() } },
                        params = {
                          suggestion_id = record.id,
                          degree = 2
                        },
                        partial = partial
                      }
                    end
                  end
                }
              end
            },
            {
              content = function(record)
                local opinion = Opinion:by_pk(app.session.member.id, record.id)
                if opinion and not opinion.fulfilled then
                  ui.image{ static = "icons/16/cross.png" }
                end
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
                    width = 50,
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
              content = function(record)
                local opinion = Opinion:by_pk(app.session.member.id, record.id)
                if opinion and opinion.fulfilled then
                    ui.image{ static = "icons/16/tick.png" }
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
                    width = 50,
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
              label_attr = { style = "width: 200px;" },
              content = function(record)
                local degree
                local opinion = Opinion:by_pk(app.session.member.id, record.id)
                if opinion then
                  degree = opinion.degree
                end
                if opinion then
                  if not opinion.fulfilled then
                    local text = ""
                    if opinion.degree > 0 then
                      text = _"Mark suggestion as implemented and express satisfaction"
                    else
                      text = _"Mark suggestion as implemented and express dissatisfaction"
                    end
                    ui.link{
                      attr = { class = "action" },
                      text = text,
                      module = "opinion",
                      action = "update",
                      routing = { default = { mode = "redirect", module = request.get_module(), view = request.get_view(), id = param.get_id_cgi(), params = param.get_all_cgi() } },
                      params = {
                        suggestion_id = record.id,
                        fulfilled = true
                      },
                      partial = partial
                    }
                  else
                    if opinion.degree > 0 then
                      text = _"Mark suggestion as not implemented and express dissatisfaction"
                    else
                      text = _"Mark suggestion as not implemented and express satisfaction"
                    end
                    ui.link{
                      attr = { class = "action" },
                      text = text,
                      module = "opinion",
                      action = "update",
                      routing = { default = { mode = "redirect", module = request.get_module(), view = request.get_view(), id = param.get_id_cgi(), params = param.get_all_cgi() } },
                      params = {
                        suggestion_id = record.id,
                        fulfilled = false
                      },
                      partial = partial
                    }
                  end
                end
              end
            },
            {
              content = function(record)
                local opinion = Opinion:by_pk(app.session.member.id, record.id)
                if opinion then
                  if (opinion.fulfilled and opinion.degree > 0) or (not opinion.fulfilled and opinion.degree < 0) then
                    ui.image{ static = "icons/16/thumb_up_green.png" }
                  else
                    ui.image{ static = "icons/16/thumb_down_red.png" }
                  end
                end
              end
            },
          }
        }
      end
    }
  end
}

function ui.filter(args)
  local name = args.name or "filter"
  local current_filter = atom.string:load(cgi.params[name]) or args.filters[1].name
  local id     = param.get_id_cgi()
  local params = param.get_all_cgi()
  ui.container{
    attr = { class = "ui_filter" },
    content = function()
      ui.container{
        attr = { class = "ui_filter_head" },
        content = function()
          slot.put(_"Filter")
          slot.put(": ")
          for i, filter in ipairs(args.filters) do
            params[name] = filter.name
            local attr = {}
            if current_filter == filter.name then
              attr.class = "active"
              filter.selector_modifier(args.selector, true)
            end
            ui.link{
              attr    = attr,
              module  = request.get_module(),
              view    = request.get_view(),
              id      = id,
              params  = params,
              content = filter.label
            }
          end
        end
      }
      ui.container{
        attr = { class = "ui_filter_content" },
        content = function()
          args.content()
        end
      }
    end
  }
end

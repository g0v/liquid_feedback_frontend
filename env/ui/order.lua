function ui.order(args)
  local name = args.name or "order"
  local current_order = atom.string:load(cgi.params[name]) or args.options[1].name
  local id     = param.get_id_cgi()
  local params = param.get_all_cgi()
  ui.container{
    attr = { class = "ui_order" },
    content = function()
      ui.container{
        attr = { class = "ui_order_head" },
        content = function()
          slot.put(_"Order by")
          slot.put(": ")
          for i, option in ipairs(args.options) do
            params[name] = option.name
            local attr = {}
            if current_order == option.name then
              attr.class = "active"
              args.selector:add_order_by(option.order_by)
            end
            ui.link{
              attr    = attr,
              module  = request.get_module(),
              view    = request.get_view(),
              id      = id,
              params  = params,
              content = option.label
            }
          end
        end
      }
      ui.container{
        attr = { class = "ui_order_content" },
        content = function()
          args.content()
        end
      }
    end
  }
end

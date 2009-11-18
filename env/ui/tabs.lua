function ui.tabs(tabs)
  ui.container{
    attr = { class = "ui_tabs" },
    content = function()
      local params = param.get_all_cgi()
      local current_tab = params["tab"]
      ui.container{
        attr = { class = "ui_tabs_links" },
        content = function()
          for i, tab in ipairs(tabs) do
            params["tab"] = i > 1 and tab.name or nil
            ui.link{
              attr = { 
                class = (
                  tab.name == current_tab and "selected" or
                  not current_tab and i == 1 and "selected" or
                  ""
                )
              },
              module = request.get_module(),
              view = request.get_view(),
              id = param.get_id_cgi(),
              text = tab.label,
              params = params
            }
          end
        end
      }
      for i, tab in ipairs(tabs) do
        if tab.name == current_tab or not current_tab and i == 1 then
          ui.container{
            attr = { class = "ui_tabs_content" },
            content = tab.content
          }
        end
      end
    end
  }
end


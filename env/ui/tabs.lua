if config.user_tab_mode == "accordeon" or config.user_tab_mode == "accordeon_first_expanded" or config.user_tab_mode == "accordeon_all_expanded" then

  function ui.tabs(tabs)
    local params = param.get_all_cgi()
    local current_tabs_string = params["tab"]
    local current_tabs = {}
    if current_tabs_string then
      for current_tab in current_tabs_string:gmatch("([^%|]+)") do
        current_tabs[current_tab] = current_tab
      end
    end

    local unique_string = param.get("tab_id") or multirand.string(16, '0123456789abcdef')

    function render_tab(tab, first)
      local params = param.get_all_cgi()
      local active = false
      for current_tab in pairs(current_tabs) do
        if tab.name == current_tab then
          active = true
        end
      end
      if config.user_tab_mode == "accordeon_first_expanded" then
        if first and current_tabs_string == nil then
          active = true
        end
      end
	 
      local link_tabs = {}
      if config.user_tab_mode == "accordeon" 
        or config.user_tab_mode == "accordeon_first_expanded"
        or config.user_tab_mode == "accordeon_all_expanded" and current_tabs_string
      then
        if not current_tabs_string and not first then
          link_tabs[tabs[1].name] = true
        end
        for current_tab in pairs(current_tabs) do
          if current_tab ~= tab.name then
            link_tabs[current_tab] = true
          end
        end
      elseif config.user_tab_mode == "accordeon_all_expanded" and not current_tabs_string then
        for i, current_tab in ipairs(tabs) do
          if current_tab.name ~= tab.name then
            link_tabs[current_tab.name] = true
          end
        end
      end
      if not active then
        link_tabs[tab.name] = true
      end

      params["tab"] = tab.name
      local onclick
      if not tab.content then
        onclick =
          'if (ui_tabs_active["' .. unique_string .. '"]["' .. tab.name .. '"]) {' ..
            'el=document.getElementById("tab' .. unique_string .. '_content_' .. tab.name .. '");' ..
            'el.innerHTML="";' ..
            'el.style.display="none";' ..
            'ui_tabs_active["' .. unique_string .. '"]["' .. tab.name .. '"]=false' ..
          '} else {' ..
            'ui_tabs_active["' .. unique_string .. '"]["' .. tab.name .. '"]=true;' ..
            'document.getElementById("tab' .. unique_string .. '_content_' .. tab.name .. '").style.display="block"; ' ..
            ui._partial_load_js{
              params = { tab = tab.name }
            } ..
          '};' ..
          'return(false);'
      end
      ui.link{
        attr = {
          name = "tab_" .. tab.name,
          class = (
            tab.name == current_tab and "ui_tabs_accordeon_head selected" .. (tab.class and (" " .. tab.class) or "") or
            not current_tab and i == 1 and "ui_tabs_accordeon_head selected" .. (tab.class and (" " .. tab.class) or "")  or
            "ui_tabs_accordeon_head" .. (tab.class and (" " .. tab.class) or "") 
          ),
          id = "tab" .. unique_string .. "_head_" .. tab.name,
          onclick = onclick,
        },
        module  = request.get_module(),
        view    = request.get_view(),
        id      = param.get_id_cgi(),
        params  = params,
        anchor  = "tab" .. unique_string .. "_" .. tab.name,
        content = function()
          if tab.icon then
            if not tab.icon.attr then
              tab.icon.attr = {}
            end
            tab.icon.attr.id = "tab" .. unique_string .. "_icon_" .. tab.name
            tab.icon.attr.width = 16
            tab.icon.attr.height = 16
            ui.image(tab.icon)
          end
          slot.put(tab.label)
        end
      }
      local expanded = active or not request.get_json_request_slots() and config.user_tab_mode == "accordeon_all_expanded" and not current_tabs_string
      ui.container{
        attr = {
          class = "ui_tabs_accordeon_content" .. (tab.class and (" " .. tab.class) or ""),
          style = not expanded and "display: none;" or nil,
          id = "tab" .. unique_string .. "_content_" .. tab.name
        },
        content = function()
          if expanded then
            ui.script{ script = 'ui_tabs_active["' .. unique_string .. '"]["' .. tab.name .. '"] = true;' }
            execute.view{
              module = tab.module,
              view = tab.view,
              id = tab.id,
              params = tab.params
            }
          else
            slot.put("&nbsp;")
          end
        end
      }
    end

    if not request.get_json_request_slots() or not current_tabs_string then
      ui.script{ script = "ui_tabs_active['" .. unique_string .. "'] = {};" }
      ui.container{
        attr = { class = "ui_tabs" },
        content = function()
          for i, tab in ipairs(tabs) do
            local static_params = tabs.static_params or {}
            static_params.tab = tab.name
            static_params.tab_id = unique_string
            ui.partial{
              module           = tabs.module,
              view             = tabs.view,
              id               = tabs.id,
              params           = static_params,
              param_names      = { "page" },
              hourglass_target = "tab" .. unique_string .. "_icon_" .. tab.name,
              target           = "tab" .. unique_string .. "_content_" .. tab.name,
              content = function()
                render_tab(tab, i == 1)
              end
            }
          end
        end
      }
    else
      local dyntab
      for i, tab in ipairs(tabs) do
        if tab.name == current_tabs_string then
          dyntab = tab
        end
      end
      if dyntab then
        local static_params = tabs.static_params or {}
        static_params.tab = dyntab.name
        static_params.tab_id = unique_string
        dyntab.params.tab_id = unique_string
        ui.partial{
          module           = tabs.module,
          view             = tabs.view,
          id               = tabs.id,
          params           = static_params,
          param_names      = { "page" },
          hourglass_target = "tab" .. unique_string .. "_icon_" .. dyntab.name,
          target           = "tab" .. unique_string .. "_content_" .. dyntab.name,
          content = function()
            execute.view{
              module = dyntab.module,
              view   = dyntab.view,
              id     = dyntab.id,
              params = dyntab.params,
            }
          end
        }
      end
    end
  end

else -- 'classic tab'

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
                    tab.name == current_tab and "selected" .. (tab.class and (" " .. tab.class) or "") or
                    not current_tab and i == 1 and "selected" .. (tab.class and (" " .. tab.class) or "") or
                    "" .. (tab.class and (" " .. tab.class) or "")
                  )
                },
                module  = request.get_module(),
                view    = request.get_view(),
                id      = param.get_id_cgi(),
                content = tab.label,
                params  = params
              }
              slot.put(" ")
            end
          end
        }
        for i, tab in ipairs(tabs) do
          if tab.name == current_tab or not current_tab and i == 1 then
            ui.container{
              attr = { class = "ui_tabs_content" },
              content = function()
                if tab.content then
                  tab.content()
                else
                  execute.view{
                    module = tab.module,
                    view   = tab.view,
                    id     = tab.id,
                    params = tab.params,
                  }
                end
              end
            }
          end
        end
      end
    }
  end

end

local initiative = param.get("initiative", "table")
local selected = param.get("selected", atom.boolean)
local expanded = param.get("expanded", atom.boolean)
local expandable = param.get("expandable", atom.boolean)

local head_name = "initiative_head_" ..    tostring(initiative.id)
local link_name = "initiative_link_" ..    tostring(initiative.id)
local name      = "initiative_content_" .. tostring(initiative.id)
local icon_name = "initiative_icon_" ..    tostring(initiative.id)

ui.container{
  attr = { class = "ui_tabs" .. (initiative.id == for_initiative_id and " active" or "") },
  content = function()
    local web20 = config.user_tab_mode == "accordeon"
      or config.user_tab_mode == "accordeon_first_expanded"
      or config.user_tab_mode == "accordeon_all_expanded"
    local onclick
    if web20 then
      if expandable then
      onclick = 
        'if (lf_initiative_expanded["' .. name .. '"]) {' ..
          'lf_initiative_expanded["' .. name .. '"]=false;' ..
          'document.getElementById("' .. name .. '_content").innerHTML="&nbsp;";' ..
          'document.getElementById("' .. name .. '").style.display="none";' ..
        '} else {' ..
          'lf_initiative_expanded["' .. name .. '"] = true;' ..
          'document.getElementById("' .. name .. '").style.display="block"; ' ..
          'var hourglass_el = document.getElementById("' .. icon_name .. '");' ..
          'var hourglass_src = hourglass_el.src;' ..
          'hourglass_el.src = "' .. encode.url{ static = "icons/16/connect.png" } .. '";' ..
          'partialMultiLoad(' ..
            '{ trace: "trace", system_error: "system_error", ' .. name .. '_content: "default" },' ..
            '{},' ..
            '"error",' ..
            '"' .. request.get_relative_baseurl() .. 'initiative/show_partial/' .. tostring(initiative.id) .. '.html?&_webmcp_json_slots[]=default&_webmcp_json_slots[]=support&_webmcp_json_slots[]=trace&_webmcp_json_slots[]=system_error",' ..
            '{},' ..
            '{},' ..
            'function() {' ..
              'hourglass_el.src = hourglass_src;' ..
            '},' ..
            'function() {' ..
              'hourglass_el.src = hourglass_src;' ..
            '}' ..
          '); ' ..
        '}' ..
        'return(false);'
      else
        onclick = "document.location.href = document.getElementById('" .. link_name .. "').href;"
      end
    end
    local module = "initiative"
    local view = "show"
    local id = initiative.id
    local params = {}
    ui.container{
      attr = {
        name = name,
        class = "ui_tabs_accordeon_head",
        id = head_name,
        onclick = onclick,
      },
      content = function()

        ui.list{
          attr = { class = "nohover" },
          records = { { a = 1} },
          columns = {
            {
              field_attr = { style = "width: 3em; padding: 0; text-align: center;"},
              content = function()
                if initiative.issue.accepted and initiative.issue.closed and initiative.issue.ranks_available or initiative.admitted == false then 
                  ui.field.rank{ image_attr = { id = icon_name }, attr = { class = "rank" }, value = initiative.rank }
                elseif web20 then
                  ui.image{
                    attr = {
                      width = 16,
                      height = 16,
                      id = icon_name,
                      style = "float: left;"
                    },
                    static = "icons/16/script.png"
                  }
                else
                  slot.put("&nbsp;")
                end
              end
            },

            {
              field_attr = { style = "width: 110px; padding: 0;"},
              content = function()
                if initiative.issue.fully_frozen and initiative.issue.closed then
                  if initiative.issue.ranks_available then 
                    if initiative.negative_votes and initiative.positive_votes then
                      local max_value = initiative.issue.voter_count
                      ui.bargraph{
                        max_value = max_value,
                        width = 100,
                        bars = {
                          { color = "#0a0", value = initiative.positive_votes },
                          { color = "#aaa", value = max_value - initiative.negative_votes - initiative.positive_votes },
                          { color = "#a00", value = initiative.negative_votes },
                        }
                      }
                    else
                      slot.put("&nbsp;")
                    end
                  else
                    slot.put(_"Counting of votes")
                  end
                else
                  local max_value = initiative.issue.population or 0
                  ui.bargraph{
                    max_value = max_value,
                    width = 100,
                    quorum = max_value * (initiative.issue.policy.initiative_quorum_num / initiative.issue.policy.initiative_quorum_den),
                    quorum_color = "#00F",
                    bars = {
                      { color = "#0a0", value = (initiative.satisfied_supporter_count or 0) },
                      { color = "#bbb", value = (initiative.supporter_count or 0) - (initiative.satisfied_supporter_count or 0) },
                      { color = "#eee", value = max_value - (initiative.supporter_count or 0) },
                    }
                  }
                end
              end
            },
    
            {
              field_attr = { style = "padding: 0;"},
              content = function()
                local link_class = "initiative_link"
                if initiative.revoked then
                  link_class = "revoked"
                end
                if selected then
                  link_class = link_class .. " selected"
                end
                if initiative.is_supporter then
                  link_class = link_class .. " supported"
                end
                if initiative.is_potential_supporter then
                  link_class = link_class .. " potentially_supported"
                end
                ui.link{
                  attr = { id = link_name, class = link_class },
                  content = function()
                    local name
                    if initiative.name_highlighted then
                      name = encode.highlight(initiative.name_highlighted)
                    else
                      name = encode.html(initiative.shortened_name)
                    end
                    ui.tag{ content = "i" .. initiative.id .. ": " }
                    slot.put(name)
                  end,
                  module  = module,
                  view    = view,
                  id      = id,
                  params  = params,
                }
    
                if initiative.is_initiator then
                  slot.put("&nbsp;")
                  local label = _"You are initiator of this initiative"
                  ui.image{
                    attr = { alt = label, title = label },
                    static = "icons/16/user_edit.png"
                  }
                end
        
              end
            }
          }
        }
      end
    }
  end
}

if ui.is_partial_loading_enabled() then
  ui.container{
    attr = {
      id = name,
      class = "ui_tabs_accordeon_content",
      style = not expanded and "display: none;" or nil
    },
    content = function()
      ui.container{
        attr = { id = name .. "_content", style = "clear: left;" },
        content = function()
          execute.view{
            module = "initiative",
            view = "show_partial",
            params = {
              initiative = initiative,
              expanded = expanded
            }
          }
        end
      }
    end
  }
end
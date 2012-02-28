local initiative = param.get("initiative", "table")
local selected = param.get("selected", atom.boolean)

ui.list{
  attr = { class = "nohover" },
  records = { { a = 1} },
  columns = {
    {
      field_attr = { style = "width: 3em; text-align: center;"},
      content = function()
        if
          initiative.issue.accepted and initiative.issue.closed
          and initiative.issue.ranks_available or initiative.admitted == false
        then 
          ui.field.rank{ attr = { class = "rank" }, value = initiative.rank, eligible = initiative.eligible }
        else
          slot.put("&nbsp;")
        end
      end
    },

    {
      field_attr = { style = "width: 100px;"},
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
              { color = "#f7f7f7", value = max_value - (initiative.supporter_count or 0) },
            }
          }
        end
      end
    },
    {
      field_attr = { style = "width: 24px;" },
      content = function()
        if initiative.is_initiator then
          slot.put("&nbsp;")
          local label = _"You are initiator of this initiative"
          ui.image{
            attr = { alt = label, title = label },
            static = "icons/16/user_edit.png"
          }
        elseif initiative.is_supporter then
          slot.put("&nbsp;")
          local label = _"You are supporter of this initiative"
          ui.image{
            attr = { alt = label, title = label },
            static = "icons/16/thumb_up_green.png"
          }
        elseif initiative.is_potential_supporter then
          slot.put("&nbsp;")
          local label = _"You are potentially supporter of this initiative"
          ui.image{
            attr = { alt = label, title = label },
            static = "icons/16/thumb_up.png"
          }
        elseif initiative.is_supporter_via_delegation then
          slot.put("&nbsp;")
          local label = _"You are supporter of this initiative via delegation"
          ui.image{
            attr = { alt = label, title = label },
            static = "icons/16/thumb_up_green.png"
          }
        end

      end
    },
    {
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
        if initiative.is_supporter_via_delegation then
          link_class = link_class .. " supported"
        end
        ui.link{
          attr = { class = link_class },
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
          module  = "initiative",
          view    = "show",
          id      = initiative.id
        }
          
      end
    }
  }
}

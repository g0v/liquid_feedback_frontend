local initiative = param.get("initiative", "table")
local selected = param.get("selected", atom.boolean)


ui.container{ attr = { class = "initiative" }, content = function()

  ui.container{ attr = { class = "rank" }, content = function()
    if initiative.issue.accepted and initiative.issue.closed
      and initiative.issue.ranks_available or initiative.admitted == false
    then 
      ui.field.rank{ attr = { class = "rank" }, value = initiative.rank, eligible = initiative.eligible }
    elseif not initiative.issue.closed then
      ui.image{ static = "icons/16/script.png" }
    else
      ui.image{ static = "icons/16/cross.png" }
    end
  end }

  ui.container{ attr = { class = "bar" }, content = function()
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
      local quorum
      if initiative.issue.accepted then
        quorum = initiative.issue.policy.initiative_quorum_num / initiative.issue.policy.initiative_quorum_den
      else
        quorum = initiative.issue.policy.issue_quorum_num / initiative.issue.policy.issue_quorum_den
      end
      ui.bargraph{
        max_value = max_value,
        width = 100,
        quorum = max_value * quorum,
        quorum_color = "#00F",
        bars = {
          { color = "#0a0", value = (initiative.satisfied_supporter_count or 0) },
          { color = "#999", value = (initiative.supporter_count or 0) - (initiative.satisfied_supporter_count or 0) },
          { color = "#ddd", value = max_value - (initiative.supporter_count or 0) },
        }
      }
    end
  end }

  if app.session.member_id then
    ui.container{ attr = { class = "interest" }, content = function()
      if initiative.member_info.initiated then
        local label = _"You are initiator of this initiative"
        ui.image{
          attr = { alt = label, title = label },
          static = "icons/16/user_edit.png"
        }
      elseif initiative.member_info.directly_supported then
        if initiative.member_info.satisfied then
          local label = _"You are supporter of this initiative"
          ui.image{
            attr = { alt = label, title = label },
            static = "icons/16/thumb_up_green.png"
          }
        else
          local label = _"You are potential supporter of this initiative"
          ui.image{
            attr = { alt = label, title = label },
            static = "icons/16/thumb_up.png"
          }
        end
      elseif initiative.member_info.supported then
        if initiative.member_info.satisfied then
          local label = _"You are supporter of this initiative via delegation"
          ui.image{
            attr = { alt = label, title = label },
            static = "icons/16/thumb_up_green_arrow.png"
          }
        else
          local label = _"You are potential supporter of this initiative via delegation"
          ui.image{
            attr = { alt = label, title = label },
            static = "icons/16/thumb_up_arrow.png"
          }
        end
      end
    end }
  end
    
  ui.container{ attr = { class = "name" }, content = function()
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
        
  end }

end }

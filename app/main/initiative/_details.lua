local initiative = param.get("initiative", "table")

function bool2str(value)
  if value then
    return _("Yes")
  else
    return _("No")
  end
end

function dtdd(label, value)
  ui.tag{ tag = "dt", content = label }
  ui.tag{ tag = "dd", content = value }
end

ui.container{
  attr = { class = "initiative_head details_initiative" },
  content = function()
    ui.container{ attr = { class = "title" }, content = _"Initiative Details" }
    ui.container{ attr = { class = "content" }, content = function()

      ui.tag{
        tag = "dl",
        attr = { class = "details_left" },
        record = initiative,
        content = function()
          -- rest
          dtdd( _"Created", format.timestamp(initiative.created) )
          if initiative.revoked then
            dtdd( _"Revoked", format.timestamp(initiative.revoked) )
          end
          if initiative.admitted ~= nil then
            dtdd( _"Admitted", bool2str(initiative.admitted) )
          end
        end
      }

      -- voting result
      if initiative.issue.closed then
        ui.tag{
          tag = "dl",
          attr = { class = "details_right" },
          content = function()

            dtdd( _"Direct majority", bool2str(initiative.direct_majority) )
            dtdd( _"Indirect majority", bool2str(initiative.indirect_majority) )
            dtdd( _"Schulze rank", tostring(initiative.schulze_rank) .. " (" .. _("Status quo: #{rank}", { rank = initiative.issue.status_quo_schulze_rank }) .. ")" )

            local texts = {}
            if initiative.reverse_beat_path then
              texts[#texts+1] = _"reverse beat path to status quo (including ties)"
            end
            if initiative.multistage_majority then
              texts[#texts+1] = _"possibly instable result caused by multistage majority"
            end
            if #texts == 0 then
            texts[#texts+1] = _"none"
            end

            dtdd( _"Other failures", table.concat(texts, ", ") )
            dtdd( _"Eligible as winner", bool2str(initiative.eligible) )

          end
        }
      end

      slot.put("<div class='clearfix'></div>")

    end }
  end
}

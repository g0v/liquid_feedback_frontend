local areas_selector = param.get("areas_selector", "table")
local hide_membership = param.get("hide_membership", atom.boolean)

areas_selector
  :reset_fields()
  :add_field("area.id", nil, { "grouped" })
  :add_field("area.name", nil, { "grouped" })
  :add_field("member_weight", nil, { "grouped" })
  :add_field("direct_member_count", nil, { "grouped" })
  :add_field("(SELECT COUNT(*) FROM issue WHERE issue.area_id = area.id AND issue.accepted ISNULL AND issue.closed ISNULL)", "issues_new_count")
  :add_field("(SELECT COUNT(*) FROM issue WHERE issue.area_id = area.id AND issue.accepted NOTNULL AND issue.half_frozen ISNULL AND issue.closed ISNULL)", "issues_discussion_count")
  :add_field("(SELECT COUNT(*) FROM issue WHERE issue.area_id = area.id AND issue.half_frozen NOTNULL AND issue.fully_frozen ISNULL AND issue.closed ISNULL)", "issues_frozen_count")
  :add_field("(SELECT COUNT(*) FROM issue WHERE issue.area_id = area.id AND issue.fully_frozen NOTNULL AND issue.closed ISNULL)", "issues_voting_count")
  :add_field("(SELECT COUNT(*) FROM issue WHERE issue.area_id = area.id AND issue.fully_frozen NOTNULL AND issue.closed NOTNULL)", "issues_finished_count")
  :add_field("(SELECT COUNT(*) FROM issue WHERE issue.area_id = area.id AND issue.fully_frozen ISNULL AND issue.closed NOTNULL)", "issues_cancelled_count")

if app.session.member_id then
  areas_selector
    :add_field({ "(SELECT COUNT(*) FROM issue LEFT JOIN direct_voter ON direct_voter.issue_id = issue.id AND direct_voter.member_id = ? WHERE issue.area_id = area.id AND issue.fully_frozen NOTNULL AND issue.closed ISNULL AND direct_voter.member_id ISNULL)", app.session.member.id }, "issues_to_vote_count")
    :left_join("membership", "_membership", { "_membership.area_id = area.id AND _membership.member_id = ?", app.session.member.id })
    :add_field("_membership.member_id NOTNULL", "is_member", { "grouped" })
    :left_join("delegation", nil, {
      "delegation.truster_id = ? AND delegation.area_id = area.id AND delegation.scope = 'area'", app.session.member_id
    })
    :left_join("member", nil, "member.id = delegation.trustee_id")
    :add_field("member.id", "trustee_member_id", { "grouped" })
    :add_field("member.name", "trustee_member_name", { "grouped" })
else
  areas_selector:add_field("0", "issues_to_vote_count")
end


ui.container{ attr = { class = "area_list" }, content = function()

  ui.container{ attr = { class = "area head" }, content = function()

    ui.container{ attr = { class = "phases" }, content = function()

      ui.container{ attr = { class = "admission" }, content = function()
        ui.image{ static = "icons/16/new.png" }
      end }

      ui.container{ attr = { class = "discussion" }, content = function()
        ui.image{ static = "icons/16/comments.png" }
      end }

      ui.container{ attr = { class = "verification" }, content = function()
        ui.image{ static = "icons/16/lock.png" }
      end }

      ui.container{ attr = { class = "voting" }, content = function()
        ui.image{ static = "icons/16/email_open.png" }
      end }

      ui.container{ attr = { class = "finished" }, content = function()
        ui.image{ static = "icons/16/tick.png" }
      end }

      ui.container{ attr = { class = "cancelled" }, content = function()
        ui.image{ static = "icons/16/cross.png" }
      end }

    end }

  end }
    
  for i, area in ipairs(areas_selector:exec()) do

    ui.container{ attr = { class = "area" }, content = function()

      ui.container{ attr = { class = "bar" }, content = function()
        if area.member_weight and area.direct_member_count then
          local max_value = MemberCount:get()
          ui.bargraph{
            max_value = max_value,
            width = 100,
            bars = {
              { color = "#444", value = area.direct_member_count },
              { color = "#777", value = area.member_weight - area.direct_member_count },
              { color = "#ddd", value = max_value - area.member_weight },
            }
          }
        end
      end }

      if not hide_membership then
        ui.container{ attr = { class = "membership" }, content = function()
          if area.is_member then
            local text = _"Member of area"
            ui.image{
              attr = { title = text, alt = text },
              static = "icons/16/user_gray.png",
            }
          else
            slot.put('<img src="null.png" width="16" height="1" />')
          end
        end }
      end

      ui.container{ attr = { class = "delegatee" }, content = function()
        if area.trustee_member_id then
          local trustee_member = Member:by_id(area.trustee_member_id)
          local text = _("Area delegated to '#{name}'", { name = area.trustee_member_name })
          ui.image{
            attr = { class = "delegation_arrow", alt = text, title = text },
            static = "delegation_arrow_24_horizontal.png"
          }
          execute.view{
            module = "member_image",
            view = "_show",
            params = {
              member = trustee_member,
              image_type = "avatar",
              show_dummy = true,
              class = "micro_avatar",
              popup_text = text
            }
          }
        else
          slot.put('<img src="null.png" width="41" height="1" />')
        end
      end }
  
      ui.container{ attr = { class = "name" }, content = function()
        ui.link{
          text = area.name,
          module = "area",
          view = "show",
          id = area.id
        }
        slot.put(" ")
        ui.tag{ content = "" }
      end }

      ui.container{ attr = { class = "phases" }, content = function()

        ui.container{ attr = { class = "admission" }, content = function()
          ui.link{
            text = tostring(area.issues_new_count),
            module = "area",
            view = "show",
            id = area.id,
            params = { filter = "new", tab = "issues" }
          }
        end }

        ui.container{ attr = { class = "discussion" }, content = function()
          ui.link{
            text = tostring(area.issues_discussion_count),
            module = "area",
            view = "show",
            id = area.id,
            params = { filter = "accepted", tab = "issues" }
          }
        end }

        ui.container{ attr = { class = "verification" }, content = function()
          ui.link{
            text = tostring(area.issues_frozen_count),
            module = "area",
            view = "show",
            id = area.id,
            params = { filter = "half_frozen", tab = "issues" }
          }
        end }

        ui.container{ attr = { class = "voting" }, content = function()
          ui.link{
            text = tostring(area.issues_voting_count),
            module = "area",
            view = "show",
            id = area.id,
            params = { filter = "frozen", tab = "issues" }
          }
        end }

        ui.container{ attr = { class = "finished" }, content = function()
          ui.link{
            text = tostring(area.issues_finished_count),
            module = "area",
            view = "show",
            id = area.id,
            params = { filter = "finished", issue_list = "newest", tab = "issues" }
          }
        end }

        ui.container{ attr = { class = "cancelled" }, content = function()
          ui.link{
            text = tostring(area.issues_cancelled_count),
            module = "area",
            view = "show",
            id = area.id,
            params = { filter = "cancelled", issue_list = "newest", tab = "issues" }
          }
        end }

      end }
      
      slot.put("<br style='clear: right;' />")
    end }
    
  end
  
end }

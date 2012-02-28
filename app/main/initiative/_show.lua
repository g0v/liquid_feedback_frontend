local initiative = param.get("initiative", "table")
local initiator = param.get("initiator", "table")

local initiators_members_selector = initiative:get_reference_selector("initiating_members")
  :add_field("initiator.accepted", "accepted")
  :add_order_by("member.name")
if initiator and initiator.accepted then
  initiators_members_selector:add_where("initiator.accepted ISNULL OR initiator.accepted")
else
  initiators_members_selector:add_where("initiator.accepted")
end

local initiators = initiators_members_selector:exec()


local initiatives_selector = initiative.issue:get_reference_selector("initiatives")
slot.select("initiatives_list", function()
  execute.view{
    module = "initiative",
    view = "_list",
    params = {
      issue = initiative.issue,
      initiatives_selector = initiatives_selector,
      no_sort = true, highlight_initiative = initiative, limit = 3
    }
  }
end)

slot.select("initiative_head", function()

  ui.container{
    attr = { class = "initiative_name" },
    content = _("Initiative i#{id}: #{name}", { id = initiative.id, name = initiative.name })
  }

  if app.session.member_id or config.public_access == "pseudonym" or config.public_access == "full" then
    ui.tag{
      attr = { class = "initiator_names" },
      content = function()
        for i, initiator in ipairs(initiators) do
          slot.put(" ")
          ui.link{
            content = function ()
              execute.view{
                module = "member_image",
                view = "_show",
                params = {
                  member = initiator,
                  image_type = "avatar",
                  show_dummy = true,
                  class = "micro_avatar",
                  popup_text = text
                }
              }
            end,
            module = "member", view = "show", id = initiator.id
          }
          slot.put(" ")
          ui.link{
            text = initiator.name,
            module = "member", view = "show", id = initiator.id
          }
          if not initiator.accepted then
            ui.tag{ attr = { title = _"Not accepted yet" }, content = "?" }
          end
        end
      end
    }
  end

  if initiator and initiator.accepted and not initiative.issue.fully_frozen and not initiative.issue.closed and not initiative.revoked then
    slot.put(" &middot; ")
    ui.link{
      attr = { class = "action" },
      content = function()
        slot.put(_"Invite initiator")
      end,
      module = "initiative",
      view = "add_initiator",
      params = { initiative_id = initiative.id }
    }
    if #initiators > 1 then
      slot.put(" &middot; ")
      ui.link{
        content = function()
          slot.put(_"Remove initiator")
        end,
        module = "initiative",
        view = "remove_initiator",
        params = { initiative_id = initiative.id }
      }
    end
  end
  if initiator and initiator.accepted == false then
      slot.put(" &middot; ")
      ui.link{
        text   = _"Cancel refuse of invitation",
        module = "initiative",
        action = "remove_initiator",
        params = {
          initiative_id = initiative.id,
          member_id = app.session.member.id
        },
        routing = {
          ok = {
            mode = "redirect",
            module = "initiative",
            view = "show",
            id = initiative.id
          }
        }
      }
  end
  if app.session.member_id then
    execute.view{
      module = "supporter",
      view = "_show_box",
      params = {
        initiative = initiative
      }
    }
  end

end )


util.help("initiative.show")


if initiative.issue.ranks_available and initiative.admitted then
  local class = initiative.rank == 1 and "admitted_info" or "not_admitted_info"
  ui.container{
    attr = { class = class },
    content = function()
      local max_value = initiative.issue.voter_count
      slot.put("&nbsp;")
      local positive_votes = initiative.positive_votes
      local negative_votes = initiative.negative_votes
      local sum_votes = initiative.positive_votes + initiative.negative_votes
      local function perc(votes, sum)
        if sum > 0 and votes > 0 then return " (" .. string.format( "%.f", votes * 100 / sum ) .. "%)" end
        return ""
      end
      slot.put(_"Yes" .. ": <b>" .. tostring(positive_votes) .. perc(positive_votes, sum_votes) .. "</b>")
      slot.put(" &middot; ")
      slot.put(_"Abstention" .. ": <b>" .. tostring(max_value - initiative.negative_votes - initiative.positive_votes)  .. "</b>")
      slot.put(" &middot; ")
      slot.put(_"No" .. ": <b>" .. tostring(initiative.negative_votes) .. perc(negative_votes, sum_votes) .. "</b>")
      slot.put(" &middot; ")
      slot.put("<b>")
      if initiative.winner then
        slot.put(_"Approved")
      elseif initiative.rank then
        slot.put(_("Not approved (rank #{rank})", { rank = initiative.rank }))
      else
        slot.put(_"Not approved")
      end
      slot.put("</b>")
    end
  }
end

if initiative.admitted == false then
  local policy = initiative.issue.policy
  ui.container{
    attr = { class = "not_admitted_info" },
    content = _("This initiative has not been admitted! It failed the quorum of #{quorum}.", { quorum = format.percentage(policy.initiative_quorum_num / policy.initiative_quorum_den) })
  }
end

if initiative.issue.state == "cancelled" then
  local policy = initiative.issue.policy
  ui.container{
    attr = { class = "not_admitted_info" },
    content = _("This issue has been cancelled. It failed the quorum of #{quorum}.", { quorum = format.percentage(policy.issue_quorum_num / policy.issue_quorum_den) })
  }
end

if initiative.revoked then
  ui.container{
    attr = { class = "revoked_info" },
    content = function()
      slot.put(_("This initiative has been revoked at #{revoked}", { revoked = format.timestamp(initiative.revoked) }))
      local suggested_initiative = initiative.suggested_initiative
      if suggested_initiative then
        slot.put("<br /><br />")
        slot.put(_("The initiators suggest to support the following initiative:"))
        slot.put(" ")
        ui.link{
          content = _("Issue ##{id}", { id = suggested_initiative.issue.id } ) .. ": " .. encode.html(suggested_initiative.name),
          module = "initiative",
          view = "show",
          id = suggested_initiative.id
        }
      end
    end
  }
end

if initiator and initiator.accepted == nil and not initiative.issue.half_frozen and not initiative.issue.closed then
  ui.container{
    attr = { class = "initiator_invite_info" },
    content = function()
      slot.put(_"You are invited to become initiator of this initiative.")
      slot.put(" ")
      ui.link{
        image  = { static = "icons/16/tick.png" },
        text   = _"Accept invitation",
        module = "initiative",
        action = "accept_invitation",
        id     = initiative.id,
        routing = {
          default = {
            mode = "redirect",
            module = request.get_module(),
            view = request.get_view(),
            id = param.get_id_cgi(),
            params = param.get_all_cgi()
          }
        }
      }
      slot.put(" ")
      ui.link{
        image  = { static = "icons/16/cross.png" },
        text   = _"Refuse invitation",
        module = "initiative",
        action = "reject_initiator_invitation",
        params = {
          initiative_id = initiative.id,
          member_id = app.session.member.id
        },
        routing = {
          default = {
            mode = "redirect",
            module = request.get_module(),
            view = request.get_view(),
            id = param.get_id_cgi(),
            params = param.get_all_cgi()
          }
        }
      }
    end
  }
  slot.put("<br />")
end


local supporter

if app.session.member_id then
  supporter = app.session.member:get_reference_selector("supporters")
    :add_where{ "initiative_id = ?", initiative.id }
    :optional_object_mode()
    :exec()
end

if supporter and not initiative.issue.closed then
  local old_draft_id = supporter.draft_id
  local new_draft_id = initiative.current_draft.id
  if old_draft_id ~= new_draft_id then
    ui.container{
      attr = { class = "draft_updated_info" },
      content = function()
        slot.put(_"The draft of this initiative has been updated!")
        slot.put(" ")
        ui.link{
          content = _"Show diff",
          module = "draft",
          view = "diff",
          params = {
            old_draft_id = old_draft_id,
            new_draft_id = new_draft_id
          }
        }
        if not initiative.revoked then
          slot.put(" ")
          ui.link{
            text   = _"Refresh support to current draft",
            module = "initiative",
            action = "add_support",
            id     = initiative.id,
            routing = {
              default = {
                mode = "redirect",
                module = "initiative",
                view = "show",
                id = initiative.id
              }
            }
          }
        end
      end
    }
  end
end

execute.view{
  module = "initiative",
  view = "show_tab",
  params = {
    initiative = initiative,
    initiator = initiator
  }
}

if initiative.issue.snapshot then
  ui.field.timestamp{ label = _"Last snapshot:", value = initiative.issue.snapshot }
end




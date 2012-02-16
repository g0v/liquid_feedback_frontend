local areas_selector = param.get("areas_selector", "table")

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

local label_attr = { style = "text-align: right; width: 4em;" }
local field_attr = { style = "text-align: right; width: 4em;" }

ui.list{
  attr = { class = "area_list", style = "width: 100%; table-layout: fixed;" },
  records = areas_selector:exec(),
  columns = {
    {
      label_attr = { style = "width: 2em;" },
      content = function(record)
        if record.is_member then
          local text = _"Member of area"
          ui.image{
            attr = { title = text, alt = text, style = "vertical-align: middle;" },
            static = "icons/16/user_gray.png",
          }
        end
      end
    },
    {
      label_attr = { style = "width: 2em;" },
      content = function(record)
        if record.trustee_member_id then
          local trustee_member = Member:by_id(record.trustee_member_id)
          local text = _("Area delegated to '#{name}'", { name = record.trustee_member_name })
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
        end
      end
    },
    {
      label_attr = { style = "width: 110px" },
      content = function(record)
        if record.member_weight and record.direct_member_count then
          local max_value = MemberCount:get()
          ui.bargraph{
            max_value = max_value,
            width = 100,
            bars = {
              { color = "#444", value = record.direct_member_count },
              { color = "#777", value = record.member_weight - record.direct_member_count },
              { color = "#ddd", value = max_value - record.member_weight },
            }
          }
        end
      end
    },
    {
      label_attr = { style = "width: 100%" },
      content = function(record)
        ui.link{
          text = record.name,
          module = "area",
          view = "show",
          id = record.id
        }
      end
    },
    {
      label = function()
        local title = _"New"
        ui.image{
          attr = { title = title, alt = title },
          static = "icons/16/new.png"
        }
      end,
      field_attr = field_attr,
      label_attr = label_attr,
      content = function(record)
        ui.link{
          text = tostring(record.issues_new_count),
          module = "area",
          view = "show",
          id = record.id,
          params = { filter = "new", tab = "issues" }
        }
      end
    },
    {
      label = function()
        local title = _"Discussion"
        ui.image{
          attr = { title = title, alt = title },
          static = "icons/16/comments.png"
        }
      end,
      field_attr = field_attr,
      label_attr = label_attr,
      content = function(record)
        ui.link{
          text = tostring(record.issues_discussion_count),
          module = "area",
          view = "show",
          id = record.id,
          params = { filter = "accepted", tab = "issues" }
        }
      end
    },
    {
      label = function()
        local title = _"Frozen"
        ui.image{
          attr = { title = title, alt = title },
          static = "icons/16/lock.png"
        }
      end,
      field_attr = field_attr,
      label_attr = label_attr,
      content = function(record)
        ui.link{
          text = tostring(record.issues_frozen_count),
          module = "area",
          view = "show",
          id = record.id,
          params = { filter = "half_frozen", tab = "issues" }
        }
      end
    },
    {
      label = function()
        local title = _"Voting"
        ui.image{
          attr = { title = title, alt = title },
          static = "icons/16/email_open.png"
        }
      end,
      field_attr = field_attr,
      label_attr = label_attr,
      content = function(record)
        ui.link{
          text = tostring(record.issues_voting_count),
          module = "area",
          view = "show",
          id = record.id,
          params = { filter = "frozen", tab = "issues" }
        }
      end
    },
    {
      label = function()
        local title = _"Finished"
        ui.image{
          attr = { title = title, alt = title },
          static = "icons/16/tick.png"
        }
      end,
      field_attr = field_attr,
      label_attr = label_attr,
      content = function(record)
        ui.link{
          text = tostring(record.issues_finished_count),
          module = "area",
          view = "show",
          id = record.id,
          params = { filter = "finished", issue_list = "newest", tab = "issues" }
        }
      end
    },
    {
      label = function()
        local title = _"Cancelled"
        ui.image{
          attr = { title = title, alt = title },
          static = "icons/16/cross.png"
        }
      end,
      field_attr = field_attr,
      label_attr = label_attr,
      content = function(record)
        ui.link{
          text = tostring(record.issues_cancelled_count),
          module = "area",
          view = "show",
          id = record.id,
          params = { filter = "cancelled", issue_list = "newest", tab = "issues" }
        }
      end
    },
    {
      content = function(record)
        if record.issues_to_vote_count > 0 then
          ui.link{
            attr = { class = "not_voted" },
            text = _"Not yet voted" .. ": " .. tostring(record.issues_to_vote_count),
            module = "area",
            view = "show",
            id = record.id,
            params = {
              filter = "frozen",
              filter_voting = "not_voted",
              tab = "issues"
            }
          }
        end
      end
    },
  }
}
--[[
ui.bargraph_legend{
  width = 25,
  bars = {
    { color = "#444", label = _"Direct membership" },
    { color = "#777", label = _"Membership by delegation" },
    { color = "#ddd", label = _"No membership at all" },
  }
}

slot.put("<br /> &nbsp; ")


if app.session.member_id then
  ui.image{
    attr = { title = title, alt = title },
    static = "icons/16/user_gray.png"
  }
  slot.put(" ")
  slot.put(_"Member of area")
  slot.put(" &nbsp; ")

  ui.image{
    attr = { title = title, alt = title },
    static = "icons/16/link.png"
  }
  slot.put(" ")
  slot.put(_"Area delegated")
  slot.put(" &nbsp; ")
end

ui.image{
  attr = { title = title, alt = title },
  static = "icons/16/new.png"
}
slot.put(" ")
slot.put(_"New")
slot.put(" &nbsp; ")

ui.image{
  attr = { title = title, alt = title },
  static = "icons/16/comments.png"
}
slot.put(" ")
slot.put(_"Discussion")
slot.put(" &nbsp; ")

ui.image{
  attr = { title = title, alt = title },
  static = "icons/16/lock.png"
}
slot.put(" ")
slot.put(_"Frozen")
slot.put(" &nbsp; ")

ui.image{
  attr = { title = title, alt = title },
  static = "icons/16/email_open.png"
}
slot.put(" ")
slot.put(_"Voting")
slot.put(" &nbsp; ")

ui.image{
  attr = { title = title, alt = title },
  static = "icons/16/tick.png"
}
slot.put(" ")
slot.put(_"Finished")
slot.put(" &nbsp; ")

ui.image{
  attr = { title = title, alt = title },
  static = "icons/16/cross.png"
}
slot.put(" ")
slot.put(_"Cancelled")

--]]
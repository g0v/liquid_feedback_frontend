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
  :add_field({ "(SELECT COUNT(*) FROM issue LEFT JOIN direct_voter ON direct_voter.issue_id = issue.id AND direct_voter.member_id = ? WHERE issue.area_id = area.id AND issue.fully_frozen NOTNULL AND issue.closed ISNULL AND direct_voter.member_id ISNULL)", app.session.member.id }, "issues_to_vote_count")
  :add_field("(SELECT COUNT(*) FROM issue WHERE issue.area_id = area.id AND issue.fully_frozen NOTNULL AND issue.closed NOTNULL)", "issues_finished_count")
  :add_field("(SELECT COUNT(*) FROM issue WHERE issue.area_id = area.id AND issue.fully_frozen ISNULL AND issue.closed NOTNULL)", "issues_cancelled_count")

ui.order{
  name = name,
  selector = areas_selector,
  options = {
    {
      name = "member_weight",
      label = _"Population",
      order_by = "area.member_weight DESC"
    },
    {
      name = "direct_member_count",
      label = _"Direct member count",
      order_by = "area.direct_member_count DESC"
    },
    {
      name = "az",
      label = _"A-Z",
      order_by = "area.name"
    },
    {
      name = "za",
      label = _"Z-A",
      order_by = "area.name DESC"
    }
  },
  content = function()
    ui.list{
      records = areas_selector:exec(),
      columns = {
        {
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
          label = _"New",
          field_attr = { style = "text-align: right;" },
          content = function(record)
            ui.link{
              text = tostring(record.issues_new_count),
              module = "area",
              view = "show",
              id = record.id,
              params = { filter = "new" }
            }
          end
        },
        {
          label = _"Discussion",
          field_attr = { style = "text-align: right;" },
          content = function(record)
            ui.link{
              text = tostring(record.issues_discussion_count),
              module = "area",
              view = "show",
              id = record.id,
              params = { filter = "accepted" }
            }
          end
        },
        {
          label = _"Frozen",
          field_attr = { style = "text-align: right;" },
          content = function(record)
            ui.link{
              text = tostring(record.issues_frozen_count),
              module = "area",
              view = "show",
              id = record.id,
              params = { filter = "half_frozen" }
            }
          end
        },
        {
          label = _"Voting",
          field_attr = { style = "text-align: right;" },
          content = function(record)
            ui.link{
              text = tostring(record.issues_voting_count),
              module = "area",
              view = "show",
              id = record.id,
              params = { filter = "frozen" }
            }
          end
        },
        {
          label = _"Not yet voted",
          field_attr = { style = "text-align: right;" },
          content = function(record)
            ui.link{
              attr = { class = record.issues_to_vote_count > 0 and "not_voted" or nil },
              text = tostring(record.issues_to_vote_count),
              module = "area",
              view = "show",
              id = record.id,
              params = { filter = "frozen", filter_voting = "not_voted" }
            }
          end
        },
        {
          label = _"Finished",
          field_attr = { style = "text-align: right;" },
          content = function(record)
            ui.link{
              text = tostring(record.issues_finished_count),
              module = "area",
              view = "show",
              id = record.id,
              params = { filter = "finished", issue_list = "newest" }
            }
          end
        },
        {
          label = _"Cancelled",
          field_attr = { style = "text-align: right;" },
          content = function(record)
            ui.link{
              text = tostring(record.issues_cancelled_count),
              module = "area",
              view = "show",
              id = record.id,
              params = { filter = "cancelled", issue_list = "newest" }
            }
          end
        },
      }
    }
  end
}

ui.bargraph_legend{
  width = 25,
  bars = {
    { color = "#444", label = _"Direct membership" },
    { color = "#777", label = _"Membership by delegation" },
    { color = "#ddd", label = _"No membership at all" },
  }
}


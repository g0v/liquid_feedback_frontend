local areas_selector = param.get("areas_selector", "table")

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
        }
      }
    }
  end
}
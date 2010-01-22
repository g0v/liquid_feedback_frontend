slot.put_into("title", _"Manage timeline filters")

slot.select("actions", function()
  ui.link{
    content = function()
        ui.image{ static = "icons/16/cancel.png" }
        slot.put(_"Back to timeline")
    end,
    module = "timeline",
    action = "update"
  }
end)

local timeline_filters = app.session.member:get_setting_maps_by_key("timeline_filters")

ui.list{
  records = timeline_filters,
  columns = {
    {
      name = "subkey"
    },
    {
      content = function(timeline_filter)
        ui.link{
          attr = { class = "action" },
          content = function()
              slot.put(_"Delete filter")
          end,
          module = "timeline",
          action = "delete_filter",
          params = { 
            name = timeline_filter.subkey
          }
        }
      end
    }
  }
}
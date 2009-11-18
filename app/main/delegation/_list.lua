local selector = param.get("selector", "table")

ui.paginate{
  selector = selector,
  content = function()
    ui.list{
      records = selector:exec(),
      columns = {
        {
          label = _"Truster",
          content = function(record)
            ui.link{
              content = record.truster.name,
              module = "member",
              view = "show",
              id = record.truster.id
            }
          end
        },
        {
          label = _"Trustee",
          content = function(record)
            ui.link{
              content = record.trustee.name,
              module = "member",
              view = "show",
              id = record.trustee.id
            }
          end
        },
        {
          label = _"Area",
          content = function(record)
            if record.area then
              ui.field.text{ value = record.area.name }
            end
          end
        },
        {
          label = _"Issue",
          content = function(record)
            if record.issue then
              ui.field.text{ value = record.issue.id }
            end
          end
        },
      }
    }
  end
}

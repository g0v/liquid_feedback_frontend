ui.list{
  records = param.get("drafts", "table"),
  columns = {
    {
      label = _"Id",
      name = "id"
    },
    {
      label = _"Created at",
      content = function(record)
        ui.field.text{ value = format.timestamp(record.created) }
      end
    },
    {
      label = _"Author",
      name = "author_name"
    },
    {
      content = function(record)
        ui.link{
          attr = { class = "action" },
          text = _"Show",
          module = "draft",
          view = "show",
          id = record.id
        }
      end
    }
  }
}

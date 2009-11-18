local opinions_selector = param.get("opinions_selector", "table")

ui.list{
  records = opinions_selector:exec(),
  columns = {
    {
      label = _"Member login",
      name = "member_login"
    },
    {
      label = _"Member name",
      name = "member_name"
    },
    {
      label = _"Degree",
      name = "degree"
    },
    {
      label = _"Fulfilled",
      name = "fulfilled"
    },
  }
}
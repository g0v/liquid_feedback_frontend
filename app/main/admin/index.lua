slot.put_into("title", _"Admin menu")


ui.link{
  text = _"Policies",
  module = "admin",
  view = "policy_list",
}

slot.put("<br /><br />")


ui.link{
  text = _"Units",
  module = "admin",
  view = "unit_list",
}

  slot.put("<br /><br />")

ui.link{
  text = _"Members",
  module = "admin",
  view = "member_list",
}


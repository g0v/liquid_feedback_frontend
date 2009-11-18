slot.put_into("title", _"Admin menu")

ui.link{
  text = "Members",
  module = "admin",
  view = "member_list",
}

slot.put("<br />")

ui.link{
  text = "Areas",
  module = "admin",
  view = "area_list",
}

slot.put("<br />")


ui.link{
  text = "Policies",
  module = "admin",
  view = "policy_list",
}


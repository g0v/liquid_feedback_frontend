slot.put_into("title", _"Member list")

execute.view{
  module = "member",
  view = "_list",
  params = { members_selector = Member:new_selector():add_order_by("login") }
}

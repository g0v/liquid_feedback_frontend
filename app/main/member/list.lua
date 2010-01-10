slot.put_into("title", _"Member list")

util.help("member.list")

execute.view{
  module = "member",
  view = "_list",
  params = { members_selector = Member:new_selector() }
}

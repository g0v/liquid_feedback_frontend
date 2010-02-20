execute.view{
  module = "member",
  view = "show_tab",
  params = { 
    member = param.get("member", "table")
  }
}
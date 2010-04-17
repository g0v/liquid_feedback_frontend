execute.view{
  module = "member",
  view = "show_tab",
  params = { 
    member = param.get("member", "table"),
    show_as_homepage = param.get("show_as_homepage", atom.boolean)
  }
}
local member = Member:by_id(param.get_id())

slot.select("title", function()
  ui.image{
    attr = { class = "avatar" },
    module = "member",
    view = "avatar",
    extension = "jpg",
    id = member.id
  }
end)

slot.put_into("title", encode.html(_"Member '#{member}'":gsub("#{member}", member.name)))

if member.id == app.session.member.id then
  slot.put_into("actions", _"That's me!")
else
  slot.select("actions", function()
    ui.link{
      content = function()
        ui.image{ static = "icons/16/book_add.png" }
        slot.put(encode.html(_"Add to my contacts"))
      end,
      module  = "contact",
      action  = "add_member",
      id      = member.id
    }
  end)
end


execute.view{
  module = "member",
  view = "_show",
  params = { member = member }
}


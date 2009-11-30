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
  --TODO performance
  local contact = Contact:by_pk(app.session.member.id, member.id)
  if contact then
    slot.select("actions", function()
      ui.field.text{ value = _"You have saved this member as contact." }
      ui.link{
        text = _"Remove from contacts",
        module = "contact",
        action = "remove_member",
        id = contact.other_member_id,
        routing = {
          default = {
            mode = "redirect",
            module = request.get_module(),
            view = request.get_view(),
            id = param.get_id_cgi(),
            params = param.get_all_cgi()
          }
        }
      }
    end)
  else
    slot.select("actions", function()
      ui.link{
        content = function()
          ui.image{ static = "icons/16/book_add.png" }
          slot.put(encode.html(_"Add to my contacts"))
        end,
        module  = "contact",
        action  = "add_member",
        id      = member.id,
        routing = {
          default = {
            mode = "redirect",
            module = request.get_module(),
            view = request.get_view(),
            id = param.get_id_cgi(),
            params = param.get_all_cgi()
          }
        }
      }
    end)
  end
end


execute.view{
  module = "member",
  view = "_show",
  params = { member = member }
}


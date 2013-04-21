local member = Member:by_id(param.get_id())

if not member or not member.activated then
  error("access denied")
end

app.html_title.title = member.name
app.html_title.subtitle = _("Member")

ui.title( _("Member '#{member}'", { member = member.name }) )

ui.actions(function()

  ui.container{
    attr = { class = "left" },
    content = function()

      ui.link{
        text    = _"Member history",
        module  = "member",
        view    = "history",
        id      = member.id
      }

      if not member.active then
        slot.put(" &middot; ")
        ui.tag{
          attr = { class = "deactivated_member_info" },
          content = _"This member is inactive."
        }
      end

      if member.locked or member.locked_import then
        slot.put(" &middot; ")
        ui.tag{
          attr = { class = "deactivated_member_info" },
          content = _"This member is locked."
        }
      end

      slot.put(" &middot; ")
      ui.link{
        text    = _"Voted",
        module  = "member",
        view    = "show",
        id      = member.id,
        params  = { tab = "closed", filter_interest = "voted", filter_delegation = "direct" }
      }

    end
  }

  if app.session.member_id and member.id ~= app.session.member.id then

    ui.container{
      attr = { class = "right" },
      content = function()

        --TODO performance
        local contact = Contact:by_pk(app.session.member.id, member.id)
        if contact then
          ui.link{
            text   = _"Remove from contacts",
            module = "contact",
            action = "remove_member",
            id     = contact.other_member_id,
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
        elseif member.activated then
          ui.link{
            text    = _"Add to my contacts",
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
        end

        slot.put(" &middot; ")

        local ignored_member = IgnoredMember:by_pk(app.session.member.id, member.id)
        if ignored_member then
          ui.tag{
            attr = { class = "interest" },
            content = _"You have ignored this member."
          }
          slot.put(" ")
          ui.link{
            text   = "(" .. _"Stop ignoring member" .. ")",
            module = "member",
            action = "update_ignore_member",
            id     = member.id,
            params = { delete = true },
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
        elseif member.activated then
          ui.link{
            attr = {
              class = "interest",
              title = _"Ignoring a member means, that you don't get anymore email notifications about the actions of this user."
            },
            text    = _"Ignore member",
            module  = "member",
            action  = "update_ignore_member",
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
        end

      end
    }

  end

  slot.put('<div class="clearfix"></div>')

end)

util.help("member.show", _"Member page")

execute.view{
  module = "member",
  view = "_show",
  params = { member = member }
}

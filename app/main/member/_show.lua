local member = param.get("member", "table")

ui.tabs{
  {
    name = "profile",
    label = _"Profile",
    content = function()
      ui.form{
        attr = { class = "member vertical" },
        record = member,
        readonly = true,
        content = function()

          ui.container{
            attr = { class = "right" },
            content = function()

            execute.view{
              module = "member_image",
              view = "_show",
              params = {
                member = member,
                image_type = "photo"
              }
            }

            ui.container{
              attr = { class = "contact_data" },
              content = function()
              end
            }

            end
          }

          if member.admin then
            ui.field.boolean{ label = _"Admin?",       name = "admin" }
          end
          if member.locked then
            ui.field.boolean{ label = _"Locked?",      name = "locked" }
          end
          if member.ident_number then
            ui.field.text{    label = _"Ident number", name = "ident_number" }
          end
          ui.field.text{ label = _"Name", name = "name" }

          if member.realname and #member.realname > 0 then
            ui.field.text{ label = _"Real name", name = "realname" }
          end
          if member.email and #member.email > 0 then
            ui.field.text{ label = _"email", name = "email" }
          end
          if member.xmpp_address and #member.xmpp_address > 0 then
            ui.field.text{ label = _"xmpp", name = "xmpp_address" }
          end
          if member.website and #member.website > 0 then
            ui.field.text{ label = _"Website", name = "website" }
          end
          if member.phone and #member.phone > 0 then
            ui.field.text{ label = _"Phone", name = "phone" }
          end
          if member.mobile_phone and #member.mobile_phone > 0 then
            ui.field.text{ label = _"Mobile phone", name = "mobile_phone" }
          end
          if member.address and #member.address > 0 then
            ui.container{
              content = function()
                ui.tag{
                  tag = "label",
                  attr = { class = "ui_field_label" },
                  content = _"Address"
                }
                ui.tag{
                  tag = "span",
                  content = function()
                    slot.put(encode.html_newlines(member.address))
                  end
                }
              end
            }
          end
          if member.profession and #member.profession > 0 then
            ui.field.text{ label = _"Profession", name = "profession" }
          end
          if member.birthday and #member.birthday > 0 then
            ui.field.text{ label = _"Birthday", name = "birthday" }
          end
          if member.organizational_unit and #member.organizational_unit > 0 then
            ui.field.text{ label = _"Organizational unit", name = "organizational_unit" }
          end
          if member.internal_posts and #member.internal_posts > 0 then
            ui.field.text{ label = _"Internal posts", name = "internal_posts" }
          end
          if member.external_memberships and #member.external_memberships > 0 then
            ui.field.text{ label = _"Memberships", name = "external_memberships", multiline = true }
          end
          if member.external_posts and #member.external_posts > 0 then
            ui.field.text{ label = _"Posts", name = "external_posts", multiline = true }
          end
          slot.put('<br style="clear: right;" />')

        end
      }
      if member.statement and #member.statement > 0 then
        ui.container{
          attr = { class = "member_statement wiki" },
          content = function()
            slot.put(format.wiki_text(member.statement))
          end
        }
      end
    end
  },
  {
    name = "areas",
    label = _"Areas",
    content = function()
      execute.view{
        module = "area",
        view = "_list",
        params = { areas_selector = member:get_reference_selector("areas") }
      }
    end
  },
  {
    name = "issues",
    label = _"Issues",
    content = function()
      execute.view{
        module = "issue",
        view = "_list",
        params = { issues_selector = member:get_reference_selector("issues") }
      }
    end
  },
  {
    name = "supported_initiatives",
    label = _"Supported initiatives",
    content = function()
      execute.view{
        module = "initiative",
        view = "_list",
        params = { initiatives_selector = member:get_reference_selector("supported_initiatives") }
      }
    end
  },
  {
    name = "initiatied_initiatives",
    label = _"Initiated initiatives",
    content = function()
      execute.view{
        module = "initiative",
        view = "_list",
        params = { initiatives_selector = member:get_reference_selector("initiated_initiatives") }
      }
    end
  },
  {
    name = "incoming_delegations",
    label = _"Incoming delegations",
    content = function()
      execute.view{
        module = "delegation",
        view = "_list",
        params = { delegations_selector = member:get_reference_selector("incoming_delegations"), incoming = true }
      }
    end
  },
  {
    name = "Outgoing delegations",
    label = _"Outgoing delegations",
    content = function()
      execute.view{
        module = "delegation",
        view = "_list",
        params = { delegations_selector = member:get_reference_selector("outgoing_delegations"), outgoing = true }
      }
    end
  },
  {
    name = "contacts",
    label = _"Published contacts",
    content = function()
      execute.view{
        module = "member",
        view = "_list",
        params = { members_selector = member:get_reference_selector("saved_members"):add_where("public") }
      }
    end
  },
}

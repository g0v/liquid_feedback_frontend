local member = param.get("member", "table")

local include_private_data = param.get("include_private_data", atom.boolean)

if not member then
  local member_id = param.get("member_id", atom.integer)
  if member_id then
    member = Member:by_id(member_id)
  end
end

ui.form{
  attr = { class = "member_statement member vertical" },
  record = member,
  readonly = true,
  content = function()

    slot.put("<br />")

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

      end
    }

    -- edit links
    if member.id == app.session.member_id then
      ui.link{
        content = function()
          slot.put(encode.html(_"Edit profile"))
        end,
        module  = "member",
        view    = "edit"
      }
      slot.put(" &middot; ")
      ui.link{
        content = function()
          slot.put(encode.html(_"Upload avatar/photo"))
        end,
        module  = "member",
        view    = "edit_images"
      }
      slot.put("<br/><br/>")
    end

    if member.name then
      ui.field.text{ label = _"Screen name", name = "name" }
    end
    if include_private_data and member.login then
      ui.field.text{    label = _"Login name", name = "login" }
      ui.field.text{    label = _"Notification email", name = "notify_email" }
    end

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
        attr = { class = "ui_field_multiline" },
        content = function()
          ui.tag{
            tag = "label",
            attr = { class = "ui_field_label" },
            content = _"Address"
          }
          ui.tag{
            tag = "span",
            content = function()
              slot.put(encode.html_newlines(encode.html(member.address)))
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
      ui.container{
        attr = { class = "ui_field_multiline" },
        content = function()
          ui.tag{
            tag = "label",
            attr = { class = "ui_field_label" },
            content = _"Memberships"
          }
          ui.tag{
            tag = "span",
            content = function()
              slot.put(encode.html_newlines(encode.html(member.external_memberships)))
            end
          }
        end
      }
    end
    if member.external_posts and #member.external_posts > 0 then
      ui.container{
        attr = { class = "ui_field_multiline" },
        content = function()
          ui.tag{
            tag = "label",
            attr = { class = "ui_field_label" },
            content = _"Posts"
          }
          ui.tag{
            tag = "span",
            content = function()
              slot.put(encode.html_newlines(encode.html(member.external_posts)))
            end
          }
        end
      }
    end
    if member.admin then
      ui.field.text{ label = _"Admin?", value = _"Yes" }
    end
    if member.last_activity then
      ui.field.text{ label = _"Last activity (updated daily)", value = format.date(member.last_activity) or _"not yet" }
    end
    if member.statement and #member.statement > 0 then
      slot.put("<br />")
      slot.put("<br />")
      ui.container{
        attr = { class = " wiki" },
        content = function()
          slot.put(member:get_content("html"))
        end
      }
    end
    slot.put("<br style=\"clear: both;\" /><br />")
  end
}

slot.put("<br />")

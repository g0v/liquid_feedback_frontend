slot.put_into("title", _"Edit my profile")

slot.select("actions", function()
  ui.link{
    content = function()
        ui.image{ static = "icons/16/cancel.png" }
        slot.put(_"Cancel")
    end,
    module = "index",
    view = "index"
  }
end)

util.help("member.edit", _"Edit my page")

ui.form{
  record = app.session.member,
  attr = { class = "vertical" },
  module = "member",
  action = "update",
  routing = {
    ok = {
      mode = "redirect",
      module = "index",
      view = "index"
    }
  },
  content = function()
    ui.field.text{ label = _"Organizational unit", name = "organizational_unit" }
    ui.field.text{ label = _"Internal posts", name = "internal_posts" }
    ui.field.text{ label = _"Real name", name = "realname" }
    ui.field.text{ label = _"Birthday" .. " YYYY-MM-DD ", name = "birthday", attr = { id = "profile_birthday" } }
    ui.script{ static = "gregor.js/gregor.js" }
    util.gregor("profile_birthday", "document.getElementById('timeline_search_date').form.submit();")
    ui.field.text{ label = _"Address", name = "address", multiline = true }
    ui.field.text{ label = _"email", name = "email" }
    ui.field.text{ label = _"xmpp", name = "xmpp_address" }
    ui.field.text{ label = _"Website", name = "website" }
    ui.field.text{ label = _"Phone", name = "phone" }
    ui.field.text{ label = _"Mobile phone", name = "mobile_phone" }
    ui.field.text{ label = _"Profession", name = "profession" }
    ui.field.text{ label = _"External memberships", name = "external_memberships", multiline = true }
    ui.field.text{ label = _"External posts", name = "external_posts", multiline = true }

    ui.field.select{
      label = _"Wiki engine for statement",
      name = "formatting_engine",
      foreign_records = {
        { id = "rocketwiki", name = "RocketWiki" },
        { id = "compat", name = _"Traditional wiki syntax" }
      },
      attr = {id = "formatting_engine"},
      foreign_id = "id",
      foreign_name = "name",
      value = param.get("formatting_engine")
    }
    ui.tag{
      tag = "div",
      content = function()
        ui.tag{
          tag = "label",
          attr = { class = "ui_field_label" },
          content = function() slot.put("&nbsp;") end,
        }
        ui.tag{
          content = function()
            ui.link{
              text = _"Syntax help",
              module = "help",
              view = "show",
              id = "wikisyntax",
              attr = {onClick="this.href=this.href.replace(/wikisyntax[^.]*/g, 'wikisyntax_'+getElementById('formatting_engine').value)"}
            }
            slot.put(" ")
            ui.link{
              text = _"(new window)",
              module = "help",
              view = "show",
              id = "wikisyntax",
              attr = {target = "_blank", onClick="this.href=this.href.replace(/wikisyntax[^.]*/g, 'wikisyntax_'+getElementById('formatting_engine').value)"}
            }
          end
        }
      end
    }
    ui.field.text{
      label = _"Statement",
      name = "statement",
      multiline = true, 
      attr = { style = "height: 50ex;" },
      value = param.get("statement")
    }

    
    ui.submit{ value = _"Save" }
  end
}
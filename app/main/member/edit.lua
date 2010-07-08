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
    ui.field.text{ label = _"Statement", name = "statement", multiline = true, attr = { style = "height: 10em;" } }
    ui.submit{ value = _"Save" }
  end
}
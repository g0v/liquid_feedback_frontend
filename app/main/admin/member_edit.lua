local id = param.get_id()

local member = Member:by_id(id)

if member then
  slot.put_into("title", encode.html(_("Member: '#{login}' (#{name})", { login = member.login, name = member.name })))
else
  slot.put_into("title", encode.html(_"Register new member"))
end

ui.form{
  attr = { class = "vertical" },
  module = "admin",
  action = "member_update",
  id = member and member.id,
  record = member,
  readonly = not app.session.member.admin,
  routing = {
    default = {
      mode = "redirect",
      modules = "admin",
      view = "member_list"
    }
  },
  content = function()
    ui.field.text{     label = _"Identification", name = "identification" }
    ui.field.text{     label = _"Notification email", name = "notify_email" }
    ui.field.boolean{  label = _"Admin?",       name = "admin" }

    ui.multiselect{ label              = _"Voting privileges",
                    name               = "units_with_voting_right[]",
                    foreign_records    = Unit:new_selector():exec(),
                    foreign_id         = "id",
                    foreign_name       = "name",
                    connecting_records = {},
                    foreign_reference  = "id",
    }
    slot.put("<br /><br />")

    ui.field.boolean{  label = _"Send invite?",       name = "invite_member" }
    ui.submit{         text  = _"Save" }
  end
}

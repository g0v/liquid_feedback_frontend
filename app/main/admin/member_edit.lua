local id = param.get_id()

local member = Member:by_id(id)

if member then
  slot.put_into("title", encode.html(_("Member: '#{login}' (#{name})", { login = member.login, name = member.name })))
else
  slot.put_into("title", encode.html(_"Register new member"))
end

local units = Unit:new_selector()
  :add_field("privilege.voting_right", "voting_right")
  :left_join("privilege", nil, { "privilege.member_id = ? AND privilege.unit_id = unit.id", member.id })
  :exec()
  
  
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

    slot.put("<br />")
    
    for i, unit in ipairs(units) do
      ui.field.boolean{
        name = "unit_" .. unit.id,
        label = unit.name,
        value = unit.voting_right
      }
    end
    slot.put("<br /><br />")

    ui.field.boolean{  label = _"Send invite?",       name = "invite_member" }
    ui.submit{         text  = _"Save" }
  end
}

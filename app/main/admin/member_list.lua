slot.put_into("title", _"Member list")

slot.select("actions", function()
  ui.link{
    attr = { class = { "admin_only" } },
    text = _"Register new member",
    module = "admin",
    view = "member_edit"
  }
  if param.get("show_locked") then
    ui.link{
      attr = { class = { "admin_only" } },
      text = _"Show active members",
      module = "admin",
      view = "member_list"
    }
  else
    ui.link{
      attr = { class = { "admin_only" } },
      text = _"Show locked members",
      module = "admin",
      view = "member_list",
      params = { show_locked = true }
    }
  end
end)

local members_selector

if param.get("show_locked", atom.boolean) then
  members_selector = Member:new_selector()
    :add_where("not active")
    :add_order_by("login")
else
  members_selector = Member:new_selector()
    :add_where("active")
    :add_order_by("login")
end

ui.paginate{
  selector = members_selector,
  content = function() 
    ui.list{
      records = members_selector:exec(),
      columns = {
        {
          field_attr = { style = "text-align: right;" },
          label = _"Id",
          name = "id"
        },
        {
          label = _"Login",
          name = "login"
        },
        {
          label = _"Name",
          content = function(record)
            util.put_highlighted_string(record.name)
          end
        },
        {
          label = _"Ident number",
          name = "ident_number"
        },
        {
          label = _"Admin?",
          name = "admin"
        },
        {
          content = function(record)
            if app.session.member.admin and not record.active then
              ui.field.text{ value = "locked" }
            end
          end
        },
        {
          content = function(record)
            if app.session.member.admin then
              ui.link{
                attr = { class = "action admin_only" },
                text = _"Edit",
                module = "admin",
                view = "member_edit",
                id = record.id
              }
            end
          end
        }
      }
    }
  end
}
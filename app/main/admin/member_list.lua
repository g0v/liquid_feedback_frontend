local search               = param.get("search")
local search_admin         = param.get("search_admin",         atom.boolean)
local search_locked        = param.get("search_locked",        atom.boolean)
local search_not_activated = param.get("search_not_activated", atom.boolean)
local search_inactive      = param.get("search_inactive",      atom.boolean)

ui.title(_"Member list")

ui.actions(function()
  ui.link{
    attr = { class = { "admin_only" } },
    text = _"Register new member",
    module = "admin",
    view = "member_edit"
  }
end)


ui.form{
  module = "admin", view = "member_list",
  attr = { class = "member_list_form" },
  content = function()

    ui.field.text{ label = _"Search for members", name = "search", value = search }

    ui.field.boolean{ label = _"Admin",         name = "search_admin",         value = search_admin }
    ui.field.boolean{ label = _"Locked",        name = "search_locked",        value = search_locked }
    ui.field.boolean{ label = _"Not activated", name = "search_not_activated", value = search_not_activated }
    ui.field.boolean{ label = _"Inactive",      name = "search_inactive",      value = search_inactive }

    ui.submit{ value = _"Start search" }

  end
}

if not search then
  return
end

local members_selector = Member:build_selector{
  admin_search               = search,
  admin_search_admin         = search_admin,
  admin_search_locked        = search_locked,
  admin_search_not_activated = search_not_activated,
  admin_search_inactive      = search_inactive,
  order = "identification"
}
members_selector:add_order_by("id")


ui.paginate{
  selector = members_selector,
  per_page = 30,
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
          label = _"Identification",
          name = "identification"
        },
        {
          label = _"Screen name",
          name = "name"
        },
        {
          content = function(record)
            if record.admin then
              ui.field.text{ value = _"Admin" }
            end
          end
        },
        {
          content = function(record)
            if record.locked then
              ui.field.text{ value = _"Locked" }
            end
          end
        },
        {
          content = function(record)
            if not record.activated then
              ui.field.text{ value = _"Not activated" }
            elseif not record.active then
              ui.field.text{ value = _"Inactive" }
            else
              ui.field.text{ value = _"Active" }
            end
          end
        },
        {
          content = function(record)
            ui.link{
              attr = { class = "action admin_only" },
              text = _"Edit",
              module = "admin",
              view = "member_edit",
              id = record.id,
              params = {
                search               = search,
                search_admin         = search_admin,
                search_locked        = search_locked,
                search_not_activated = search_not_activated,
                search_inactive      = search_inactive,
              }
            }
          end
        }
      }
    }
  end
}
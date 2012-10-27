local search           = param.get("search")
local search_imported  = param.get("search_imported",  atom.integer)
local search_admin     = param.get("search_admin",     atom.integer)
local search_activated = param.get("search_activated", atom.integer)
local search_locked    = param.get("search_locked",    atom.integer)
local search_active    = param.get("search_active",    atom.integer)

ui.title(_"Member list")

ui.actions(function()

  ui.link{
    text = _"Admin menu",
    module = "admin",
    view = "index"
  }
  slot.put(" &middot; ")

  ui.link{
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

    ui.field.select{
      name = "search_imported",
      foreign_records  = {
        {id = 0, name = "---" .. _"Imported" .. "?---"},
        {id = 1, name = _"Imported"},
        {id = 2, name = _"Not imported"}
      },
      foreign_id = "id",
      foreign_name = "name",
      selected_record  = search_imported
    }

    ui.field.select{
      name = "search_admin",
      foreign_records  = {
        {id = 0, name = "---" .. _"Admin" .. "?---"},
        {id = 1, name = _"Admin"},
        {id = 2, name = _"Not admin"}
      },
      foreign_id = "id",
      foreign_name = "name",
      selected_record  = search_admin
    }

    ui.field.select{
      name = "search_activated",
      foreign_records  = {
        {id = 0, name = "---" .. _"Activated" .. "?---"},
        {id = 1, name = _"Activated"},
        {id = 2, name = _"Not activated"}
      },
      foreign_id = "id",
      foreign_name = "name",
      selected_record  = search_activated
    }

    ui.field.select{
      name = "search_locked",
      foreign_records  = {
        {id = 0, name = "---" .. _"Locked" .. "?---"},
        {id = 1, name = _"Locked"},
        {id = 2, name = _"Not locked"}
      },
      foreign_id = "id",
      foreign_name = "name",
      selected_record  = search_locked
    }

    ui.field.select{
      name = "search_active",
      foreign_records  = {
        {id = 0, name = "---" .. _"Active" .. "?---"},
        {id = 1, name = _"Active"},
        {id = 2, name = _"Not active"}
      },
      foreign_id = "id",
      foreign_name = "name",
      selected_record  = search_active
    }

    ui.submit{ value = _"Start search" }

  end
}

if not search then
  return
end

local members_selector = Member:build_selector{
  admin_search           = search,
  admin_search_imported  = search_imported,
  admin_search_admin     = search_admin,
  admin_search_activated = search_activated,
  admin_search_locked    = search_locked,
  admin_search_active    = search_active,
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
          content = function(record)
            if (record.name) then
              ui.link{
                text = record.name,
                module = "member",
                view = "show",
                id = record.id
              }
            end
          end
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
              attr = { class = "action" },
              text = _"Edit",
              module = "admin",
              view = "member_edit",
              id = record.id,
              params = {
                search           = search,
                search_imported  = search_imported,
                search_admin     = search_admin,
                search_activated = search_activated,
                search_locked    = search_locked,
                search_active    = search_active,
                page             = param.get("page")
              }
            }
          end
        }
      }
    }
  end
}
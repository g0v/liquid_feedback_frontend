local show_locked = param.get("show_locked", atom.boolean)

local locked = show_locked or false
local search = param.get("search")
if search then
  locked = nil
end

local members_selector = Member:build_selector{
  admin_search = search,
  locked = locked,
  order = "identification"
}


ui.title(_"Member list")


slot.select("head", function()
  ui.container{ attr = { class = "content" }, content = function()
    ui.container{ attr = { class = "actions" }, content = function()
      ui.link{
        attr = { class = { "admin_only" } },
        text = _"Register new member",
        module = "admin",
        view = "member_edit"
      }
      slot.put(" &middot; ")
      if show_locked then
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
    end }
  end }
end)


ui.form{
  module = "admin", view = "member_list",
  content = function()
  
    ui.field.text{ label = _"Search for members", name = "search" }
    
    ui.submit{ value = _"Start search" }
  
  end
}

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
          label = _"Admin?",
          content = function(record)
            if record.admin then
              ui.field.text{ value = "admin" }
            end
          end
        },
        {
          content = function(record)
            if record.locked then
              ui.field.text{ value = "locked" }
            elseif not record.activated then
              ui.field.text{ value = "not activated" }
            elseif not record.active then
              ui.field.text{ value = "inactive" }
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
              id = record.id
            }
          end
        }
      }
    }
  end
}
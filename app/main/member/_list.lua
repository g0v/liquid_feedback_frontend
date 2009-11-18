local members_selector = param.get("members_selector", "table")

ui.paginate{
  selector = members_selector,
  content = function() 
    ui.list{
      records = members_selector:exec(),
      columns = {
        {
          content    = function(record)
            ui.image{
              attr = { style="height: 24px;" },
              module = "member",
              view = "avatar",
              extension = "jpg",
              id = record.id
            }
          end
        },
        {
          label = _"Login",
          content    = function(record)
            ui.link{
              text   = record.login,
              module = "member",
              view   = "show",
              id     = record.id
            }
          end
        },
        {
          label = _"Name",
          content = function(record)
            ui.link{
              content = function()
                util.put_highlighted_string(record.name)
              end,
              module = "member",
              view   = "show",
              id     = record.id
            }
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
          label = "Locked?",
          content = function(record)
            ui.field.boolean{ value = record.locked }
          end
        },
        {
         content    = function(record)
            ui.link{
              attr   = { class = "action" },
              text   = _"Add to my contacts",
              module = "contact",
              action = "add_member",
              id     = record.id,
              routing = {
                default = {
                  mode = "redirect",
                  module = request.get_module(),
                  view = request.get_view(),
                  id = param.get_id_cgi(),
                  params = param.get_all_cgi()
                }
              }
            }
          end
        }
      }
    }
  end
}
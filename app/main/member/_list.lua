local members_selector = param.get("members_selector", "table")

ui.order{
  name = "member_list",
  selector = members_selector,
  options = {
    {
      name = "name",
      label = _"A-Z",
      order_by = "name"
    },
    {
      name = "name_desc",
      label = _"Z-A",
      order_by = "name DESC"
    },
  },
  content = function()
    ui.paginate{
      selector = members_selector,
      per_page = 100,
      content = function() 
        ui.container{
          attr = { class = "member_list" },
          content = function()
            for i, member in ipairs(members_selector:exec()) do
              execute.view{
                module = "member",
                view = "_show_thumb",
                params = { member = member }
              }
            end
          end
        }
            slot.put('<br style="clear: left;" />')
      end
    }
  end
}
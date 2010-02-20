local members_selector = param.get("members_selector", "table")
local initiative = param.get("initiative", "table")
local issue = param.get("issue", "table")
local trustee = param.get("trustee", "table")
local initiator = param.get("initiator", "table")

ui.add_partial_param_names{ "member_list" }

local filter = {
  label = _"Order by",
  name = "member_list",
  {
    name = "name",
    label = _"A-Z",
    selector_modifier = function(selector) selector:add_order_by("name") end
  },
  {
    name = "name_desc",
    label = _"Z-A",
    selector_modifier = function(selector) selector:add_order_by("name DESC") end
  },
  {
    name = "newest",
    label = _"Newest",
    selector_modifier = function(selector) selector:add_order_by("created DESC, id DESC") end
  },
  {
    name = "oldest",
    label = _"Oldest",
    selector_modifier = function(selector) selector:add_order_by("created, id") end
  },
}

if initiative then
  filter[#filter] = {
    name = "delegations",
    label = _"Delegations",
    selector_modifier = function(selector) selector:add_order_by("weight DESC") end
  }
end

ui.filters{
  label = _"Change order",
  selector = members_selector,
  filter,
  content = function()
    ui.paginate{
      selector = members_selector,
      per_page = 100,
      content = function() 
        ui.container{
          attr = { class = "member_list" },
          content = function()
            local members = members_selector:exec()
            local columns = { 
              {
                label = _"Name",
                content = function(member)
                  ui.link{
                    module = "member",
                    view = "show",
                    id = member.id,
                    content = function()
                      ui.image{
                        attr = { width = 48, height = 48 },
                        module    = "member",
                        view      = "avatar",
                        id        = member.id,
                        extension = "jpg"
                      }
                    end
                  }
                end
              },
              {
                label = _"Name",
                content = function(member)
                  ui.link{
                    module = "member",
                    view = "show",
                    id = member.id,
                    content = member.name
                  }
                  if member.admin then
                    ui.image{
                      attr = { 
                        alt   = _"Administrator",
                        title = _"Administrator"
                      },
                      static = "icons/16/cog.png"
                    }
                  end
                  -- TODO performance
                  local contact = Contact:by_pk(app.session.member.id, member.id)
                  if contact then
                    ui.image{
                      attr = { 
                        alt   = _"Saved as contact",
                        title = _"Saved as contact"
                      },
                      static = "icons/16/book_edit.png"
                    }
                  end
                end
              }
            }

            if initiative then
              columns[#columns+1] = {
                label = _"Delegations",
                field_attr = { style = "text-align: right;" },
                content = function(member)
                  if member.weight > 1 then
                    ui.link{
                      content = member.weight,
                      module = "support",
                      view = "show_incoming",
                      params = { member_id = member.id, initiative_id = initiative.id }
                    }
                  end
                end
              }
            end

            for i, member in ipairs(members) do
              execute.view{
                module = "member",
                view = "_show_thumb",
                params = {
                  member = member,
                  initiative = initiative,
                  issue = issue,
                  trustee = trustee,
                  initiator = initiator
                }
              }
            end

          end
        }
        slot.put('<br style="clear: left;" />')
      end
    }
  end
}

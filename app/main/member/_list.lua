local members_selector = param.get("members_selector", "table")
local initiative = param.get("initiative", "table")
local issue = param.get("issue", "table")
local trustee = param.get("trustee", "table")
local initiator = param.get("initiator", "table")

local options = {
  {
    name = "newest",
    label = _"Newest",
    order_by = "created DESC, id DESC"
  },
  {
    name = "oldest",
    label = _"Oldest",
    order_by = "created, id"
  },
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
}

if initiative then
  options[#options+1] = {
    name = "delegations",
    label = _"Delegations",
    order_by = "weight DESC"
  }
end

ui.order{
  name = "member_list",
  selector = members_selector,
  options = options,
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

--[[            ui.list{
              records = members,
              columns = columns
            }
--]]
---[[
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
---]]
          end
        }
        slot.put('<br style="clear: left;" />')
        if issue then
          ui.field.timestamp{ label = _"Last snapshot:", value = issue.snapshot }
        end
        if initiative then
          ui.field.timestamp{ label = _"Last snapshot:", value = initiative.issue.snapshot }
        end
      end
    }
  end
}
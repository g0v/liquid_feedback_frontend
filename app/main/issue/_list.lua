local issues_selector = param.get("issues_selector", "table")

local paginate = ui.paginate

local issues

if not issues_selector then
  issues = param.get("issues", "table")
  paginate = function(args)
    args.content()
  end
end

ui.order{
  name = "issue_list",
  selector = issues_selector,
  options = {
    {
      name = "population",
      label = _"Population",
      order_by = "issue.population DESC"
    },
    {
      name = "newest",
      label = _"Newest",
      order_by = "issue.created DESC"
    },
    {
      name = "oldest",
      label = _"Oldest",
      order_by = "issue.created"
    }
  },
  content = function()
    paginate{
      selector = issues_selector,
      content = function()
        local highlight_string = param.get("highlight_string", "string")
        ui.list{
          attr = { class = "issues" },
          records = issues or issues_selector:exec(),
          columns = {
            {
              label = _"Issue",
              content = function(record)
                if not param.get("for_area_list", atom.boolean) then
                  ui.field.text{
                    value = record.area.name
                  }
                  slot.put("<br />")
                end
                ui.link{
                  text = _"Issue ##{id}":gsub("#{id}", tostring(record.id)),
                  module = "issue",
                  view = "show",
                  id = record.id
                }
                slot.put("<br />")
                slot.put("<br />")
              end
            },
            {
              label = _"State",
              content = function(record)
                ui.field.issue_state{ value = record.state }
              end
            },
            {
              label = _"Initiatives",
              content = function(record)
                execute.view{
                  module = "initiative",
                  view = "_list",
                  params = {
                    issue = record,
                    initiatives_selector = record:get_reference_selector("initiatives"),
                    highlight_string = highlight_string,
                    limit = 3
                  }
                }
              end
            },
          }
        }
    
      end
    }
  end
}
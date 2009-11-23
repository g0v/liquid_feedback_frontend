local issues_selector = param.get("issues_selector", "table")


ui.filter{
  selector = issues_selector,
  filters = {
    {
      type = "boolean",
      name = "any",
      label = _"Any",
      selector_modifier = function()  end
    },
    {
      type = "boolean",
      name = "new",
      label = _"New",
      selector_modifier = function(selector, value)
        if value then
          selector:add_where("issue.accepted ISNULL AND issue.closed ISNULL")
        end
      end
    },
    {
      type = "boolean",
      name = "accepted",
      label = _"In discussion",
      selector_modifier = function(selector, value)
        if value then
          selector:add_where("issue.accepted NOTNULL AND issue.half_frozen ISNULL AND issue.closed ISNULL")
        end
      end
    },
    {
      type = "boolean",
      name = "half_frozen",
      label = _"Frozen",
      selector_modifier = function(selector, value)
        if value then
          selector:add_where("issue.half_frozen NOTNULL AND issue.closed ISNULL")
        end
      end
    },
    {
      type = "boolean",
      name = "frozen",
      label = _"Voting",
      selector_modifier = function(selector, value)
        if value then
          selector:add_where("issue.fully_frozen NOTNULL AND issue.closed ISNULL")
        end
      end
    },
    {
      type = "boolean",
      name = "finished",
      label = _"Finished",
      selector_modifier = function(selector, value)
        if value then
          selector:add_where("issue.closed NOTNULL AND ranks_available")
        end
      end
    },
    {
      type = "boolean",
      name = "cancelled",
      label = _"Cancelled",
      selector_modifier = function(selector, value)
        if value then
          selector:add_where("issue.closed NOTNULL AND NOT ranks_available")
        end
      end
    },
  },
  content = function()
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
        ui.paginate{
          selector = issues_selector,
          content = function()
            local highlight_string = param.get("highlight_string", "string")
            local issues = issues or issues_selector:exec()
--            issues:load(initiatives)
            ui.list{
              attr = { class = "issues" },
              records = issues,
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
                    if record.state == "new" then
                      ui.image{
                        static = "icons/16/new.png"
                      }
                    end
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
                    local initiatives_selector = record:get_reference_selector("initiatives")
                    local highlight_string = param.get("highlight_string")
                    if highlight_string then
                      initiatives_selector:add_field( {'"highlight"("initiative"."name", ?)', highlight_string }, "name_highlighted")
                    end
                    execute.view{
                      module = "initiative",
                      view = "_list",
                      params = {
                        issue = record,
                        initiatives_selector = initiatives_selector,
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
  end
}

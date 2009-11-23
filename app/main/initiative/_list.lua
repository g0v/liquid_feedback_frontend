local initiatives_selector = param.get("initiatives_selector", "table")
initiatives_selector:join("issue", nil, "issue.id = initiative.issue_id")

local issue = param.get("issue", "table")

local order_options = {}

if issue and issue.ranks_available then
  order_options[#order_options+1] = {
    name = "rank",
    label = _"Rank",
    order_by = "initiative.rank"
  }
end

order_options[#order_options+1] = {
  name = "support",
  label = _"Support",
  order_by = "initiative.supporter_count::float / issue.population::float DESC"
}

order_options[#order_options+1] = {
  name = "support_si",
  label = _"Support S+I",
  order_by = "initiative.satisfied_informed_supporter_count::float / issue.population::float DESC"
}

order_options[#order_options+1] = {
  name = "newest",
  label = _"Newest",
  order_by = "initiative.created DESC"
}

order_options[#order_options+1] = {
  name = "oldest",
  label = _"Oldest",
  order_by = "initiative.created"
}

local name = "initiative_list"
if issue then
  name = "issue_" .. tostring(issue.id) ..  "_initiative_list"
end

ui.order{
  name = name,
  selector = initiatives_selector,
  options = order_options,
  content = function()
    ui.paginate{
      selector = initiatives_selector,
      content = function()
        local initiatives = initiatives_selector:exec()
        local columns = {}
        columns[#columns+1] = {
          content = function(record)
            if record.issue.accepted and record.issue.closed and record.issue.ranks_available then 
              ui.field.rank{ value = record.rank }
              if record.negative_votes and record.positive_votes then
                local max_value = record.issue.voter_count
                ui.bargraph{
                  max_value = max_value,
                  width = 200,
                  bars = {
                    { color = "#0a0", value = record.positive_votes },
                    { color = "#aaa", value = max_value - record.negative_votes - record.positive_votes },
                    { color = "#a00", value = record.negative_votes },
                  }
                }
              end
            else
              local max_value = (record.issue.population or 0)
              ui.bargraph{
                max_value = max_value,
                width = 200,
                bars = {
                  { color = "#0a0", value = (record.satisfied_supporter_count or 0) },
                  { color = "#8f8", value = (record.supporter_count or 0) - (record.satisfied_supporter_count or 0) },
                  { color = "#ddd", value = max_value - (record.supporter_count or 0) },
                }
              }
            end
          end
        }
        columns[#columns+1] = {
          content = function(record)
            ui.link{
              content = function()
                local name
                if record.name_highlighted then
                  name = encode.highlight(record.name_highlighted)
                else
                  name = encode.html(record.name)
                end
                slot.put(name)
              end,
              module = "initiative",
              view = "show",
              id = record.id
            }
            if record.issue.state == "new" then
              ui.image{
                static = "icons/16/new.png"
              }
            end
          end
        }

        ui.list{
          attr = { class = "initiatives" },
          records = initiatives,
          columns = columns
        }
      end
    }
  end
}
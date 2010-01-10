local initiatives_selector = param.get("initiatives_selector", "table")
initiatives_selector:join("issue", nil, "issue.id = initiative.issue_id")

local issue = param.get("issue", "table")

local order_options = {}

if issue and issue.ranks_available then
  order_options[#order_options+1] = {
    name = "rank",
    label = _"Rank",
    order_by = "initiative.rank, initiative.admitted DESC, vote_ratio(initiative.positive_votes, initiative.negative_votes) DESC, initiative.id"
  }
end

order_options[#order_options+1] = {
  name = "potential_support",
  label = _"Potential support",
  order_by = "initiative.supporter_count::float / issue.population::float DESC, initiative.id"
}

order_options[#order_options+1] = {
  name = "support",
  label = _"Support",
  order_by = "initiative.satisfied_supporter_count::float / issue.population::float DESC, initiative.id"
}

order_options[#order_options+1] = {
  name = "newest",
  label = _"Newest",
  order_by = "initiative.created DESC, initiative.id"
}

order_options[#order_options+1] = {
  name = "oldest",
  label = _"Oldest",
  order_by = "initiative.created, initiative.id"
}

local name = "initiative_list"
if issue then
  name = "issue_" .. tostring(issue.id) ..  "_initiative_list"
end

ui_order = ui.order

if param.get("no_sort", atom.boolean) then
  ui_order = function(args) args.content() end
  if issue.ranks_available then
    initiatives_selector:add_order_by("initiative.rank, initiative.admitted DESC, vote_ratio(initiative.positive_votes, initiative.negative_votes) DESC, initiative.id")
  else
    initiatives_selector:add_order_by("initiative.supporter_count::float / issue.population::float DESC, initiative.id")
  end
end

ui_order{
  name = name,
  selector = initiatives_selector,
  options = order_options,
  content = function()
    ui.paginate{
      selector = initiatives_selector,
      per_page = param.get("per_page", atom.number),
      content = function()
        local initiatives = initiatives_selector:exec()
        local columns = {}
        columns[#columns+1] = {
          content = function(record)
            if record.issue.accepted and record.issue.closed and record.issue.ranks_available then 
              ui.field.rank{ attr = { class = "rank" }, value = record.rank }
            end
          end
        }
        columns[#columns+1] = {
          content = function(record)
            if record.issue.accepted and record.issue.closed then
              if record.issue.ranks_available then 
                if record.negative_votes and record.positive_votes then
                  local max_value = record.issue.voter_count
                  ui.bargraph{
                    max_value = max_value,
                    width = 100,
                    bars = {
                      { color = "#0a0", value = record.positive_votes },
                      { color = "#aaa", value = max_value - record.negative_votes - record.positive_votes },
                      { color = "#a00", value = record.negative_votes },
                    }
                  }
                end
              else
                slot.put(_"Counting of votes")
              end
            else
              local max_value = (record.issue.population or 0)
              ui.bargraph{
                max_value = max_value,
                width = 100,
                bars = {
                  { color = "#0a0", value = (record.satisfied_supporter_count or 0) },
                  { color = "#777", value = (record.supporter_count or 0) - (record.satisfied_supporter_count or 0) },
                  { color = "#ddd", value = max_value - (record.supporter_count or 0) },
                }
              }
            end
          end
        }
        columns[#columns+1] = {
          content = function(record)
            local link_class
            if record.revoked then
              link_class = "revoked"
            end
            ui.link{
              attr = { class = link_class },
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
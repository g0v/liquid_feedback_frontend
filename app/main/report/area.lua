function show_issue(issue, initiatives_selector)
  ui.list{
    records = initiatives_selector:exec(),
    columns = {
      {
        label = _"Date",
        label_attr = { style = "width: 7.5em;" },
        content = function(initiative)
          slot.put(format.date(issue.closed))
        end
      },
      {
        label_attr = { style = "width: 8em;" },
        label = _"Id",
        content = function(initiative)
          ui.link{
            external = "",
            text = "#" .. tostring(issue.id) .. "." .. tostring(initiative.id),
            attr = {
              onclick =
                "openEl('initiative_" .. tostring(initiative.id) .. "');" ..
                "return(false);"
            }
          }
        end
      },
      {
        label = _"Rank",
        label_attr = { style = "width: 3em;" },
        field_attr = { style = "text-align: right;" },
        content = function(initiative)
          ui.field.rank{ value = initiative.rank }
        end
      },
      {
        label = _"Name",
        content = function(initiative)
          if initiative.rank and initiative.rank == 1 then
            slot.put("<b>")
          end
          ui.field.text{ value = initiative.name }
          if initiative.rank and initiative.rank == 1 then
            slot.put("</b>")
          end
        end
      }
    }
  }
end

function link_issue(issue)
  ui.link{
    external = "",
    attr = {
      style = "text-decoration: none;",
      name    = "issue_" .. tostring(issue.id),
      onclick =
        "openEl('issue_" .. tostring(issue.id) .. "');" ..
        "return(false);"
    },
    content = function()
      ui.heading{
        attr = { style = "background-color: #ddd; color: #000;" },
        content = _("##{id}", { id = issue.id })
      }
    end
  }
end


local area = param.get("area", "table")

local issue_selector = Issue:new_selector()
issue_selector:add_where{ "area_id = ?", area.id }
issue_selector:add_where("closed NOTNULL")
issue_selector:add_order_by("id")


local issues = issue_selector:exec()

ui.container{
  attr = {
    id = "area_" .. tostring(area.id)
  },
  content = function()

    link_area(area)

    for i, issue in ipairs(issues) do

      link_issue(issue)

      local initiatives_selector = issue:get_reference_selector("initiatives")

      local initiatives_count = initiatives_selector:count()

      initiatives_selector:add_order_by("rank")
      initiatives_selector:limit(3)

      show_issue(issue, initiatives_selector)

      if initiatives_count > 3 then
        ui.link{
          attr = {
            style = "margin-left: 8em; font-style: italic;",
            onclick = "openEl('issue_" .. tostring(issue.id) .. "'); return(false);"
          },
          content = _("and #{count} more initiatives", { count = initiatives_count - 3 }),
          external = ""
        }
      end

      slot.put("<br />")

    end

  end
}

ui.script{ script = "parents['area_" .. tostring(area.id) .. "'] = 'areas';" }

local next_issue = issues[1]
if next_issue then
  ui.script{ script = "next_issues['area_" .. tostring(area.id) .. "'] = 'issue_" .. tostring(next_issue.id) .. "';" }
end

if next_issue then
  local next_initiative = next_issue.initiatives[1]
  if next_initiative then
    ui.script{ script = "next_initiatives['area_" .. tostring(area.id) .. "'] = 'initiative_" .. tostring(next_initiative.id) .. "';" }
  end
end


for i, issue in ipairs(issues) do
  local initiatives_selector = issue:get_reference_selector("initiatives")
    :add_order_by("rank")

  local initiatives = initiatives_selector:exec()

  ui.container{
    attr = {
      id = "issue_" .. tostring(issue.id)
    },
    content = function()
      link_area(area)
      link_issue(issue)
      show_issue(issue, initiatives_selector)
    end
  }

  local previous_issue = issues[i-1]
  if previous_issue then
    ui.script{ script = "prev_issues['issue_" .. tostring(issue.id) .. "'] = 'issue_" .. tostring(previous_issue.id) .. "';" }
  end

  local next_initiative = initiatives[1]
  if next_initiative then
    ui.script{ script = "next_initiatives['issue_" .. tostring(issue.id) .. "'] = 'initiative_" .. tostring(next_initiative.id) .. "';" }
  end

  ui.script{ script = "parents['issue_" .. tostring(issue.id) .. "'] = 'area_" .. tostring(area.id) .. "';" }

  local next_issue = issues[i+1]
  if next_issue then
    ui.script{ script = "next_issues['issue_" .. tostring(issue.id) .. "'] = 'issue_" .. tostring(next_issue.id) .. "';" }
  end

  ui.script{
    script = "document.getElementById('issue_" .. tostring(issue.id) .. "').style.display = 'none';"
  }


  for j, initiative in ipairs(initiatives) do

    ui.container{
      attr = {
        id = "initiative_" .. tostring(initiative.id)
      },
      content = function()
        execute.view{
          module = "report",
          view = "initiative",
          params = { initiative = initiative }
        }
        slot.put("<br />")
        slot.put("<br />")
        slot.put("<br />")
        slot.put("<br />")
        slot.put("<br />")
      end
    }

    local previous_issue = issues[i-1]
    if previous_issue then
      ui.script{ script = "prev_issues['initiative_" .. tostring(initiative.id) .. "'] = 'issue_" .. tostring(previous_issue.id) .. "';" }
    end

    local previous_initiative = initiatives[j-1]
    if previous_initiative then
      ui.script{ script = "prev_initiatives['initiative_" .. tostring(initiative.id) .. "'] = 'initiative_" .. tostring(previous_initiative.id) .. "';" }
    end

    ui.script{ script = "parents['initiative_" .. tostring(initiative.id) .. "'] = 'issue_" .. tostring(issue.id) .. "';" }

    local next_initiative = initiatives[j+1]
    if next_initiative then
      ui.script{ script = "next_initiatives['initiative_" .. tostring(initiative.id) .. "'] = 'initiative_" .. tostring(next_initiative.id) .. "';" }
    end

    local next_issue = issues[i+1]
    if next_issue then
      ui.script{ script = "next_issues['initiative_" .. tostring(initiative.id) .. "'] = 'issue_" .. tostring(next_issue.id) .. "';" }
    end

    ui.script{
      script = "document.getElementById('initiative_" .. tostring(initiative.id) .. "').style.display = 'none';"
    }

  end
end

ui.script{
  script = "document.getElementById('area_" .. tostring(area.id) .. "').style.display = 'none';"
}


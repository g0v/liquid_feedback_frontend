
local function format_dow(dow)
  local dows = {
    _"Monday",
    _"Tuesday",
    _"Wednesday",
    _"Thursday",
    _"Friday",
    _"Saturday",
    _"Sunday"
  }
  return dows[dow+1]
end

slot.put_into("title", _"Global timeline")


ui.form{
  attr = { class = "vertical" },
  module = "timeline",
  view = "index",
  method = "get",
  content = function()
    local tmp = db:query("select EXTRACT(DOW FROM date) as dow, date FROM (SELECT (now() - (to_char(days_before, '0') || ' days')::interval)::date as date from (select generate_series(0,7) as days_before) as series) as date; ")
    local today = tmp[1].date
    for i, record in ipairs(tmp) do
      local content
      if i == 1 then
        content = _"Today"
      elseif i == 2 then
        content = _"Yesterday"
      else
        content = format_dow(record.dow)
      end
      ui.link{
        content = content,
        attr = { onclick = "el = document.getElementById('timeline_search_date'); el.value = '" .. tostring(record.date) .. "'; el.form.submit(); return(false);" },
        module = "timeline",
        view = "index",
        params = { date = record.date }
      }
      slot.put(" ")
    end
    ui.field.hidden{
      attr = { id = "timeline_search_date" },
      name = "date",
      value = param.get("date") or today
    }
    ui.field.select{
      attr = { onchange = "this.form.submit();" },
      name = "per_page",
      label = _"Issues per page",
      foreign_records = {
        { id = "10",  name = "10"   },
        { id = "25",  name = "25"   },
        { id = "50",  name = "50"   },
        { id = "100", name = "100"  },
        { id = "250", name = "250"  },
        { id = "all", name = _"All" },
      },
      foreign_id = "id",
      foreign_name = "name",
      value = param.get("per_page")
    }
    local initiatives_per_page = param.get("initiatives_per_page", atom.integer) or 3

    ui.field.select{
      attr = { onchange = "this.form.submit();" },
      name = "initiatives_per_page",
      label = _"Initiatives per page",
      foreign_records = {
        { id = 1,   name = "1"  },
        { id = 3,   name = "3"  },
        { id = 5,   name = "5"  },
        { id = 10,  name = "10" },
        { id = 25,  name = "25" },
        { id = 50,  name = "50" },
      },
      foreign_id = "id",
      foreign_name = "name",
      value = initiatives_per_page
    }
  end
}

local date = param.get("date")
if not date then
  date = "today"
end
local issues_selector = db:new_selector()
issues_selector._class = Issue

issues_selector
  :add_field("*")
  :add_where{ "sort::date = ?", date }
  :add_from{ "($) as issue", {
    Issue:new_selector()
      :add_field("''", "old_state")
      :add_field("'new'", "new_state")
      :add_field("created", "sort")
    :union(Issue:new_selector()
      :add_field("'new'", "old_state")
      :add_field("'accepted'", "new_state")
      :add_field("accepted", "sort")
      :add_where("accepted NOTNULL")
    ):union(Issue:new_selector()
      :add_field("'accepted'", "old_state")
      :add_field("'frozen'", "new_state")
      :add_field("half_frozen", "sort")
      :add_where("half_frozen NOTNULL")
    ):union(Issue:new_selector()
      :add_field("'frozen'", "old_state")
      :add_field("'voting'", "new_state")
      :add_field("fully_frozen", "sort")
      :add_where("fully_frozen NOTNULL")
    ):union(Issue:new_selector()
      :add_field("'new'", "old_state")
      :add_field("'cancelled'", "new_state")
      :add_field("closed", "sort")
      :add_where("closed NOTNULL AND accepted ISNULL")
    ):union(Issue:new_selector()
      :add_field("'accepted'", "old_state")
      :add_field("'cancelled'", "new_state")
      :add_field("closed", "sort")
      :add_where("closed NOTNULL AND half_frozen ISNULL AND accepted NOTNULL")
    ):union(Issue:new_selector()
      :add_field("'frozen'", "old_state")
      :add_field("'cancelled'", "new_state")
      :add_field("closed", "sort")
      :add_where("closed NOTNULL AND fully_frozen ISNULL AND half_frozen NOTNULL")
    ):union(Issue:new_selector()
      :add_field("'voting'", "old_state")
      :add_field("'finished'", "new_state")
      :add_field("closed", "sort")
      :add_where("closed NOTNULL AND fully_frozen NOTNULL AND half_frozen ISNULL")
    )
  }
}

execute.view{
  module = "issue",
  view = "_list",
  params = {
    issues_selector = issues_selector,
    initiatives_per_page = param.get("initiatives_per_page", atom.number),
    initiatives_no_sort = true,
    no_filter = true,
    no_sort = true,
    per_page = param.get("per_page"),
  }
}

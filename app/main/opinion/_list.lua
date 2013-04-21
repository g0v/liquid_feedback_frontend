local opinions_selector = param.get("opinions_selector", "table")
local initiative = param.get('initiative', "table")

ui.list{
  records = opinions_selector:exec(),
  columns = {
    {
      label = _"Member",
      content = function(record)

        local member = record.member
        member.weight = record.weight

        execute.view{
          module = "member",
          view = "_show_thumb",
          params = {
            member = member,
            initiative = initiative,
            issue = initiative.issue
          }
        }

      end
    },
    {
      label = _"Degree",
      label_attr = { class = "opinion" },
      field_attr = { class = "opinion" },
      content = function(record)
        if record.degree == -2 then
          slot.put(_"must not")
        elseif record.degree == -1 then
          slot.put(_"should not")
        elseif record.degree == 1 then
          slot.put(_"should")
        elseif record.degree == 2 then
          slot.put(_"must")
        end
      end
    },
    {
      label = _"Suggestion currently implemented",
      label_attr = { class = "opinion" },
      field_attr = { class = "opinion" },
      content = function(record)
        if record.fulfilled then
          slot.put(_"Yes")
        else
          slot.put(_"No")
        end
      end
    },
  }
}
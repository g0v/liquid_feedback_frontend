local show_not_in_use = param.get("show_not_in_use", atom.boolean)

local selector = Area:new_selector()
if show_not_in_use then
  selector:add_where("NOT active")
else
  selector:add_where("active")
end

local areas = selector:exec()

slot.put_into("title", _"Area list")

if app.session.member.admin then
  slot.select("actions", function()
    if show_not_in_use then
      ui.link{
        attr = { class = { "admin_only" } },
        text = _"Show areas in use",
        module = "admin",
        view = "area_list"
      }
    else
      ui.link{
        attr = { class = { "admin_only" } },
        text = _"Create new area",
        module = "admin",
        view = "area_show"
      }
      ui.link{
        attr = { class = { "admin_only" } },
        text = _"Show areas not in use",
        module = "admin",
        view = "area_list",
        params = { show_not_in_use = true }
      }
    end
  end)
end

ui.list{
  records = areas,
  columns = {
    {
      label = _"Area",
      name = "name"
    },
    {
      content = function(record)
        if app.session.member.admin then
          ui.link{
            attr = { class = { "action admin_only" } },
            text = _"Edit",
            module = "admin",
            view = "area_show",
            id = record.id
          }
        end
      end
    }
  }
}
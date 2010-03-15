local member = Member:by_id(param.get_id())

slot.put_into("title", encode.html(_("Member name history for '#{name}'", { name = member.name })))

slot.select("actions", function()
  ui.link{
    content = function()
        ui.image{ static = "icons/16/cancel.png" }
        slot.put(_"Back")
    end,
    module = "member",
    view = "show",
    id = member.id
  }
end)

local entries = member:get_reference_selector("history_entries"):add_order_by("id DESC"):exec()

ui.tag{
  tag = "table",
  content = function()
    ui.tag{
      tag = "tr",
      content = function()
        ui.tag{
          tag = "th",
          content = _("Name")
        }
        ui.tag{
          tag = "th",
          content = _("Used until")
        }
      end
    }
    ui.tag{
      tag = "tr",
      content = function()
        ui.tag{
          tag = "td",
          content = member.name
        }
        ui.tag{
          tag = "td",
          content = _"continuing"
        }
      end
    }
    for i, entry in ipairs(entries) do
      local display = false
      if (i == 1) then
        if entry.name ~= member.name then
          display = true
        end
      elseif entry.name ~= entries[i-1].name then
        display = true
      end
      if display then
        ui.tag{
          tag = "tr",
          content = function()
            ui.tag{
              tag = "td",
              content = entry.name
            }
            ui.tag{
              tag = "td",
              content = format.timestamp(entry["until"])
            }
          end
        }
      end
    end
  end
}
slot.put("<br />")
ui.container{
  content = _("This member account has been created at #{created}", { created = format.timestamp(member.created)})
}

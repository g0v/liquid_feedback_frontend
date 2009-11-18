function ui.field.satisfaction_total(args)
  ui.form_element(args, {fetch_value = true}, function(args)
    local value = args.value
    ui.tag{
      attr = { class = "satisfaction_total" },
      content = function()
        ui.tag{
          attr = { class = "value" },
          content = function()
            slot.put("(")
            slot.put(tostring(value) .. '&nbsp;')
            ui.image{
              static = "icons/16/thumb_up_green.png"
            }
            slot.put(")")
          end
        }
      end
    }
  end)
end


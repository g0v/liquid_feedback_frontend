function ui.field.potential_initiative_weight(args)
  ui.form_element(args, {fetch_value = true}, function(args)
    local value = args.value
    ui.tag{
      attr = { class = "potential_weight" },
      content = function()
        ui.tag{
          attr = { class = "value" },
          content = "(" .. tostring(value) .. ")"
        }
      end
    }
  end)
end
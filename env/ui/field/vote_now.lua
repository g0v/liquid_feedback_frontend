function ui.field.vote_now(args)
  ui.form_element(args, {fetch_value = true}, function(args)
    local value = args.value
    ui.tag{
      attr = { class = "vote_now" },
      content = function()
        ui.tag{
          attr = { class = "value" },
          content = tostring(value)
        }
      end
    }
  end)
end

function ui.field.issue_state(args)
  ui.form_element(args, {fetch_value = true}, function(args)
    local value = args.value
    local state_name = Issue:get_state_name_for_state(value)
    ui.tag{
      attr = { class = "vote_now" },
      content = function()
        ui.tag{
          attr = { class = "value" },
          content = tostring(state_name)
        }
      end
    }
  end)
end

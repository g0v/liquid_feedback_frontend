function ui.bargraph(args)
  local text = ""
  for i, bar in ipairs(args.bars) do
    if #text > 0 then
      text = text .. " / "
    end
    text = text .. tostring(bar.value)
  end
  ui.container{
    attr = {
      class = args.class or "bargraph",
      title = tostring(text)
    },
    content = function()
      local at_least_one_bar = false
      for i, bar in ipairs(args.bars) do
        if bar.value > 0 then
          at_least_one_bar = true
          local value = bar.value * args.width / args.max_value
          ui.container{
            attr = {
              style = "width: " .. tostring(value) .. "px; background-color: " .. bar.color .. ";",
            },
            content = function() slot.put("&nbsp;") end
          }
        end
      end
      if not at_least_one_bar then
        slot.put("&nbsp;")
      end
    end
  }
end

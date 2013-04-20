function ui.bargraph(args)

  local text = ""
  for i, bar in ipairs(args.bars) do
    if bar.value > 0 or not bar.hide_empty then
      if #text > 0 then
        text = text .. " / "
      end
      text = text .. tostring(bar.value)
      if bar.title then
        text = text .. " " .. bar.title
      end
    end
  end

  ui.container{
    attr = {
      class = args.class or "bargraph",
      title = (args.title_prefix or "") .. text
    },
    content = function()

      local quorum        = args.quorum        and args.quorum        * args.width / args.max_value or nil
      local quorum_direct = args.quorum_direct and args.quorum_direct * args.width / args.max_value or nil
      if quorum and quorum_direct and quorum <= quorum_direct then
        quorum = nil
      end

      local last_visible_bar = 0
      for i, bar in ipairs(args.bars) do
        if bar.value > 0 then
          last_visible_bar = i
        end
      end

      local at_least_one_bar = false
      local length = 0
      for i, bar in ipairs(args.bars) do
        if bar.value > 0 then
          at_least_one_bar = true

          local value = bar.value * args.width / args.max_value

          if quorum_direct and quorum_direct < length + value then
            local width = math.floor(math.max(quorum_direct - length - 1, 0))
            if width > 0 then
              ui.container{
                attr = {
                  style = "width: " .. tostring(width) .. "px; background-color: " .. bar.color .. ";",
                },
                content = function() slot.put("&nbsp;") end
              }
            end
            ui.container{
              attr = {
                class = "quorum",
                style = "width: 1px; background-color: #666;",
              },
              content = function() slot.put("") end
            }
            length = length + width + 1
            value = value - width
            quorum_direct = nil
          end

          if quorum and quorum < length + value then
            local width = math.floor(math.max(quorum - length - 1, 0))
            if width > 0 then
              ui.container{
                attr = {
                  style = "width: " .. tostring(width) .. "px; background-color: " .. bar.color .. ";",
                },
                content = function() slot.put("&nbsp;") end
              }
            end
            ui.container{
              attr = {
                class = "quorum",
                style = "width: 1px; background-color: #00F;",
              },
              content = function() slot.put("") end
            }
            length = length + width + 1
            value = value - width
            quorum = nil
          end

          if i == last_visible_bar then
            width = args.width - length
          else
            width = math.floor(value)
          end
          ui.container{
            attr = {
              style = "width: " .. tostring(width) .. "px; background-color: " .. bar.color .. ";",
            },
            content = function() slot.put("&nbsp;") end
          }
          length = length + width

        end
      end

      if not at_least_one_bar then
        slot.put("&nbsp;")
      end

    end
  }
end

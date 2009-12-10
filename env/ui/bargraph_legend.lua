function ui.bargraph_legend(attr)
  local width = assert(attr.width)
  local bars = assert(attr.bars)

  ui.container{
    attr = { class = "bargraph_legend" },
    content = function()
      ui.container{
        attr = { class = "bargraph_legend_label" },
        content = _"Legend:"
      }
      for i, bar in ipairs(bars) do
        ui.bargraph{
          max_value = 1,
          width = width,
          bars = {
            {
              color = bar.color,
              value = 1,
            }
          }
        }
        ui.container{
          attr = { class = "bargraph_legend_label" },
          content = bar.label
        }
      end
    end
  }

  slot.put('<br style="clear: left;" />')
end
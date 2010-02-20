slot.select("actions", function()
  ui.link{
    module = "index",
    view = "about",
    content = function()
      ui.image{ static = "icons/16/cancel.png" }
      slot.put(_"Back")
    end
  }
end)

ui.container{
  attr = { class = "wiki use_terms" },
  content = function()
    slot.put(format.wiki_text(config.use_terms))
  end
}

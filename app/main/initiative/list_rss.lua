slot.set_layout("atom")

request.force_absolute_baseurl()

local initiatives = Initiative:new_selector()
  :add_order_by("id DESC")
  :limit(25)
  :exec()

for i, initiative in ipairs(initiatives) do
  ui.tag{
    tag = "entry",
    content = function()
      ui.tag{ tag = "category", attr = { term = initiative.issue.area.name } }
      ui.tag{ tag = "author", content = initiative.current_draft.author.name }
      ui.tag{ tag = "title", content = initiative.name }
      ui.tag{ tag = "link", attr = { 
        href = encode.url{
          module = "initiative",
          view = "show",
          id = initiative.id
        }
      } }
      ui.tag{ tag = "id",  content = "initiative_" .. tostring(initiative_id) }
      ui.tag{ tag = "updated",  content = tostring(initiative.created) }
      ui.tag{ tag = "content",  content = initiative.current_draft.draft }
    end
  }
end
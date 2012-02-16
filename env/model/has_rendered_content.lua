function model.has_rendered_content(class, rendered_class, content_field_name)

  local content_field_name = content_field_name or 'content'
  
  -- render content to html, save it as rendered_class and return it
  function class.object:render_content()
    -- local draft for update
    local lock = class:new_selector()
      :add_where{ "id = ?", self.id }
      :single_object_mode()
      :for_update()
      :exec()
    -- check if there is already a rendered content
    local rendered = rendered_class:new_selector()
      :add_where{ class.table .. "_id = ?", self.id }
      :add_where{ "format = 'html'" }
      :optional_object_mode()
      :exec()
    if rendered then
      return rendered
    end
    -- create rendered_class record
    local rendered = rendered_class:new()
    rendered[class.table .. "_id"] = self.id
    rendered.format = "html"
    rendered.content = format.wiki_text(self[content_field_name], self.formatting_engine)
    rendered:save()
    -- and return it
    return rendered
  end

  -- returns rendered version for specific format
  function class.object:get_content(format)
    -- Fetch rendered_class record for specified format
    local rendered = rendered_class:new_selector()
      :add_where{ class.table .. "_id = ?", self.id }
      :add_where{ "format = ?", format }
      :optional_object_mode()
      :exec()
    -- If this format isn't rendered yet, render it
    if not rendered then
      rendered = self:render_content()
    end
    -- return rendered content
    return rendered.content
  end

end
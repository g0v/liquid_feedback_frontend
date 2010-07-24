Draft = mondelefant.new_class()
Draft.table = 'draft'

-- Many drafts belonging to an initiative
Draft:add_reference{
  mode          = 'm1',
  to            = "Initiative",
  this_key      = 'initiative_id',
  that_key      = 'id',
  ref           = 'initiative',
}

-- Many drafts are authored by a member
Draft:add_reference{
  mode          = 'm1',
  to            = "Member",
  this_key      = 'author_id',
  that_key      = 'id',
  ref           = 'author',
}

function Draft.object_get:author_name()
  return self.author and self.author.name or _"Unknown author"
end

-- render draft to html, save it as rendered_draft and return it
function Draft.object:render_content()
  -- local draft for update
  local draft_lock = Draft:new_selector()
    :add_where{ "id = ?", self.id }
    :single_object_mode()
    :for_update()
    :exec()
  -- check if there is already a rendered draft
  local rendered_draft = RenderedDraft:new_selector()
    :add_where{ "draft_id = ?", self.id }
    :add_where{ "format = 'html'" }
    :optional_object_mode()
    :exec()
  if rendered_draft then
    return rendered_draft
  end
  -- create rendered_draft record
  local rendered_draft = RenderedDraft:new()
  rendered_draft.draft_id = self.id
  rendered_draft.format = "html"
  rendered_draft.content = format.wiki_text(self.content, self.formatting_engine)
  rendered_draft:save()
  -- and return it
  return rendered_draft
end

-- returns rendered version of draft for specific format
function Draft.object:get_content(format)
  -- Fetch rendered_draft record for specified format
  local rendered_draft = RenderedDraft:new_selector()
    :add_where{ "draft_id = ?", self.id }
    :add_where{ "format = ?", format }
    :optional_object_mode()
    :exec()
  -- If this format isn't rendered yet, render it
  if not rendered_draft then
    rendered_draft = self:render_content()
  end
  -- return rendered content
  return rendered_draft.content
end
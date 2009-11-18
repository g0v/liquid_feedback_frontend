Draft = mondelefant.new_class()
Draft.table = 'draft'

Draft:add_reference{
  mode          = 'm1',
  to            = "Initiative",
  this_key      = 'initiative_id',
  that_key      = 'id',
  ref           = 'initiative',
}

Draft:add_reference{
  mode          = 'm1',
  to            = "Member",
  this_key      = 'author_id',
  that_key      = 'id',
  ref           = 'author',
}

-- reference to supporter probably not needed

function Draft.object_get:author_name()
  return self.author and self.author.name or _"Unknown author"
end

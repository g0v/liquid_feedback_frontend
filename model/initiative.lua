Initiative = mondelefant.new_class()
Initiative.table = 'initiative'

Initiative:add_reference{
  mode          = 'm1',
  to            = "Issue",
  this_key      = 'issue_id',
  that_key      = 'id',
  ref           = 'issue',
}

Initiative:add_reference{
  mode          = '1m',
  to            = "Draft",
  this_key      = 'id',
  that_key      = 'initiative_id',
  ref           = 'drafts',
  back_ref      = 'initiative',
  default_order = '"id"'
}

Initiative:add_reference{
  mode          = '1m',
  to            = "Suggestion",
  this_key      = 'id',
  that_key      = 'initiative_id',
  ref           = 'suggestions',
  back_ref      = 'initiative',
  default_order = '"id"'
}

Initiative:add_reference{
  mode          = '1m',
  to            = "Initiator",
  this_key      = 'id',
  that_key      = 'initiative_id',
  ref           = 'initiators',
  back_ref      = 'initiative',
  default_order = '"id"'
}

Initiative:add_reference{
  mode          = '1m',
  to            = "Supporter",
  this_key      = 'id',
  that_key      = 'initiative_id',
  ref           = 'supporters',
  back_ref      = 'initiative',
  default_order = '"id"'
}

Initiative:add_reference{
  mode          = '1m',
  to            = "Opinion",
  this_key      = 'id',
  that_key      = 'initiative_id',
  ref           = 'opinions',
  back_ref      = 'initiative',
  default_order = '"id"'
}

Initiative:add_reference{
  mode          = '1m',
  to            = "Vote",
  this_key      = 'id',
  that_key      = 'initiative_id',
  ref           = 'votes',
  back_ref      = 'initiative',
  default_order = '"member_id"'
}

Initiative:add_reference{
  mode                  = 'mm',
  to                    = "Member",
  this_key              = 'id',
  that_key              = 'id',
  connected_by_table    = '"initiator"',
  connected_by_this_key = 'initiative_id',
  connected_by_that_key = 'member_id',
  ref                   = 'initiating_members'
}

Initiative:add_reference{
  mode                  = 'mm',
  to                    = "Member",
  this_key              = 'id',
  that_key              = 'id',
  connected_by_table    = '"supporter"',
  connected_by_this_key = 'initiative_id',
  connected_by_that_key = 'member_id',
  ref                   = 'supporting_members'
}

function Initiative:get_search_selector(search_string)
  return self:new_selector()
    :add_field( {'"highlight"("initiative"."name", ?)', search_string }, "name_highlighted")
    :add_where{ '"initiative"."text_search_data" @@ "text_search_query"(?)', search_string }
end

function Member:get_search_selector(search_string)
  return self:new_selector()
    :add_where("active")
end


function Initiative.object_get:current_draft()
  return Draft:new_selector()
    :add_where{ '"initiative_id" = ?', self.id }
    :add_order_by('"id" DESC')
    :single_object_mode()
    :exec()
end

function Initiative.object_get:shortened_name()
  local name = self.name
  if #name > 100 then
    name = name:sub(1,100) .. "..."
  end
  return name
end

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
  default_order = '"id" DESC'
}

Initiative:add_reference{
  mode          = '1m',
  to            = "Suggestion",
  this_key      = 'id',
  that_key      = 'initiative_id',
  ref           = 'suggestions',
  back_ref      = 'initiative',
}

Initiative:add_reference{
  mode          = '1m',
  to            = "Initiator",
  this_key      = 'id',
  that_key      = 'initiative_id',
  ref           = 'initiators',
  back_ref      = 'initiative'
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
  mode          = 'm1',
  to            = "Initiative",
  this_key      = 'suggested_initiative_id',
  that_key      = 'id',
  ref           = 'suggested_initiative',
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

Initiative:add_reference{
  mode                  = 'mm',
  to                    = "Member",
  this_key              = 'id',
  that_key              = 'id',
  connected_by_table    = 'direct_supporter_snapshot',
  connected_by_this_key = 'initiative_id',
  connected_by_that_key = 'member_id',
  ref                   = 'supporting_members_snapshot'
}


function Initiative:get_search_selector(search_string)
  return self:new_selector()
    :join("draft", nil, "draft.initiative_id = initiative.id")
    :add_field( {'"highlight"("initiative"."name", ?)', search_string }, "name_highlighted")
    :add_where{ '"initiative"."text_search_data" @@ "text_search_query"(?) OR "draft"."text_search_data" @@ "text_search_query"(?)', search_string, search_string }
    :add_group_by('"initiative"."id"')
    :add_group_by('"initiative"."issue_id"')
    :add_group_by('"initiative"."name"')
    :add_group_by('"initiative"."discussion_url"')
    :add_group_by('"initiative"."created"')
    :add_group_by('"initiative"."revoked"')
    :add_group_by('"initiative"."revoked_by_member_id"')
    :add_group_by('"initiative"."admitted"')
    :add_group_by('"initiative"."supporter_count"')
    :add_group_by('"initiative"."informed_supporter_count"')
    :add_group_by('"initiative"."satisfied_supporter_count"')
    :add_group_by('"initiative"."satisfied_informed_supporter_count"')
    :add_group_by('"initiative"."positive_votes"')
    :add_group_by('"initiative"."negative_votes"')
    :add_group_by('"initiative"."direct_majority"')
    :add_group_by('"initiative"."indirect_majority"')
    :add_group_by('"initiative"."schulze_rank"')
    :add_group_by('"initiative"."better_than_status_quo"')
    :add_group_by('"initiative"."worse_than_status_quo"')
    :add_group_by('"initiative"."reverse_beat_path"')
    :add_group_by('"initiative"."multistage_majority"')
    :add_group_by('"initiative"."eligible"')
    :add_group_by('"initiative"."winner"')
    :add_group_by('"initiative"."rank"')
    :add_group_by('"initiative"."suggested_initiative_id"')
    :add_group_by('"initiative"."text_search_data"')
    :add_group_by('"issue"."population"')
    :add_group_by("_initiator.member_id")
    :add_group_by("_supporter.member_id")
    :add_group_by("_direct_supporter_snapshot.member_id")
end

--function Member:get_search_selector(search_string)
--  return self:new_selector()
--    :add_where("active")
--end


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

function Initiative.object_get:initiator_names()
  local members = Member:new_selector()
    :join("initiator", nil, "initiator.member_id = member.id")
    :add_where{ "initiator.initiative_id = ?", self.id }
    :add_where{ "initiator.accepted" }
    :exec()

  local member_names = {}
  for i, member in ipairs(members) do
    member_names[#member_names+1] = member.name
  end
  return member_names
end


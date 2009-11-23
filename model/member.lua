Member = mondelefant.new_class()
Member.table = 'member'

Member:add_reference{
  mode          = '11',
  to            = "MemberImage",
  this_key      = 'id',
  that_key      = 'member_id',
  ref           = 'image',
  back_ref      = 'member'
}

Member:add_reference{
  mode          = '1m',
  to            = "Contact",
  this_key      = 'id',
  that_key      = 'member_id',
  ref           = 'contacts',
  back_ref      = 'member',
  default_order = '"other_member_id"'
}

Member:add_reference{
  mode          = '1m',
  to            = "Contact",
  this_key      = 'id',
  that_key      = 'member_id',
  ref           = 'foreign_contacts',
  back_ref      = 'other_member',
  default_order = '"member_id"'
}

Member:add_reference{
  mode          = '1m',
  to            = "Session",
  this_key      = 'id',
  that_key      = 'member_id',
  ref           = 'sessions',
  back_ref      = 'member',
  default_order = '"ident"'
}

Member:add_reference{
  mode          = '1m',
  to            = "Draft",
  this_key      = 'id',
  that_key      = 'author_id',
  ref           = 'drafts',
  back_ref      = 'author',
  default_order = '"id"'
}

Member:add_reference{
  mode          = '1m',
  to            = "Suggestion",
  this_key      = 'id',
  that_key      = 'author_id',
  ref           = 'suggestions',
  back_ref      = 'author',
  default_order = '"id"'
}

Member:add_reference{
  mode          = '1m',
  to            = "Membership",
  this_key      = 'id',
  that_key      = 'member_id',
  ref           = 'memberships',
  back_ref      = 'member',
  default_order = '"area_id"'
}

Member:add_reference{
  mode          = '1m',
  to            = "Interest",
  this_key      = 'id',
  that_key      = 'member_id',
  ref           = 'interests',
  back_ref      = 'member',
  default_order = '"id"'
}

Member:add_reference{
  mode          = '1m',
  to            = "Initiator",
  this_key      = 'id',
  that_key      = 'member_id',
  ref           = 'initiators',
  back_ref      = 'member',
  default_order = '"id"'
}

Member:add_reference{
  mode          = '1m',
  to            = "Supporter",
  this_key      = 'id',
  that_key      = 'member_id',
  ref           = 'supporters',
  back_ref      = 'member'
}

Member:add_reference{
  mode          = '1m',
  to            = "Opinion",
  this_key      = 'id',
  that_key      = 'member_id',
  ref           = 'opinions',
  back_ref      = 'member',
  default_order = '"id"'
}

Member:add_reference{
  mode          = '1m',
  to            = "Delegation",
  this_key      = 'id',
  that_key      = 'truster_id',
  ref           = 'outgoing_delegations',
  back_ref      = 'truster',
  default_order = '"id"'
}

Member:add_reference{
  mode          = '1m',
  to            = "Delegation",
  this_key      = 'id',
  that_key      = 'trustee_id',
  ref           = 'incoming_delegations',
  back_ref      = 'trustee',
  default_order = '"id"'
}

Member:add_reference{
  mode          = '1m',
  to            = "DirectVoter",
  this_key      = 'id',
  that_key      = 'member_id',
  ref           = 'direct_voter',
  back_ref      = 'member',
  default_order = '"issue_id"'
}

Member:add_reference{
  mode          = '1m',
  to            = "Vote",
  this_key      = 'id',
  that_key      = 'member_id',
  ref           = 'vote',
  back_ref      = 'member',
  default_order = '"issue_id", "initiative_id"'
}

Member:add_reference{
  mode                  = 'mm',
  to                    = "Member",
  this_key              = 'id',
  that_key              = 'id',
  connected_by_table    = 'contact',
  connected_by_this_key = 'member_id',
  connected_by_that_key = 'other_member_id',
  ref                   = 'saved_members',
}

Member:add_reference{
  mode                  = 'mm',
  to                    = "Member",
  this_key              = 'id',
  that_key              = 'id',
  connected_by_table    = 'contact',
  connected_by_this_key = 'other_member_id',
  connected_by_that_key = 'member_id',
  ref                   = 'saved_by_members',
}

Member:add_reference{
  mode                  = 'mm',
  to                    = "Area",
  this_key              = 'id',
  that_key              = 'id',
  connected_by_table    = 'membership',
  connected_by_this_key = 'member_id',
  connected_by_that_key = 'area_id',
  ref                   = 'areas'
}

Member:add_reference{
  mode                  = 'mm',
  to                    = "Issue",
  this_key              = 'id',
  that_key              = 'id',
  connected_by_table    = 'interest',
  connected_by_this_key = 'member_id',
  connected_by_that_key = 'issue_id',
  ref                   = 'issues'
}

Member:add_reference{
  mode                  = 'mm',
  to                    = "Initiative",
  this_key              = 'id',
  that_key              = 'id',
  connected_by_table    = 'initiator',
  connected_by_this_key = 'member_id',
  connected_by_that_key = 'initiative_id',
  ref                   = 'initiated_initiatives'
}

Member:add_reference{
  mode                  = 'mm',
  to                    = "Initiative",
  this_key              = 'id',
  that_key              = 'id',
  connected_by_table    = 'supporter',
  connected_by_this_key = 'member_id',
  connected_by_that_key = 'initiative_id',
  ref                   = 'supported_initiatives'
}

function Member.object:set_password(password)
  local hash = os.crypt(
    password,
    "$1$" .. multirand.string(
      8,
      "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz./"
    )
  )
  assert(hash, "os.crypt failed")
  self.password = hash
end

function Member.object:check_password(password)
  if type(password) == "string" and type(self.password) == "string" then
    return os.crypt(password, self.password) == self.password
  else
    return false
  end
end

function Member.object_get:published_contacts()
  return Member:new_selector()
    :join('"contact"', nil, '"contact"."other_member_id" = "member"."id"')
    :add_where{ '"contact"."member_id" = ?', self.id }
    :add_where("public")
    :exec()
end

function Member:by_login_and_password(login, password)
  local selector = self:new_selector()
  selector:add_where{'"login" = ?', login, password }
  selector:add_where('"active"')
  selector:optional_object_mode()
  local member = selector:exec()
  if member and member:check_password(password) then
    return member
  else
    return nil
  end
end

function Member:get_search_selector(search_string)
  return self:new_selector()
    :add_field( {'"highlight"("member"."name", ?)', search_string }, "name_highlighted")
    :add_where{ '"member"."text_search_data" @@ "text_search_query"(?)', search_string }
    :add_where("active")
end


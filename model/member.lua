Member = mondelefant.new_class()
Member.table = 'member'

Member:add_reference{
  mode          = "1m",
  to            = "MemberHistory",
  this_key      = 'id',
  that_key      = 'member_id',
  ref           = 'history_entries',
  back_ref      = 'member'
}

Member:add_reference{
  mode          = '1m',
  to            = "MemberImage",
  this_key      = 'id',
  that_key      = 'member_id',
  ref           = 'images',
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
  back_ref      = 'member'
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
  selector:add_where{'"login" = ?', login }
  selector:add_where('"active"')
  selector:optional_object_mode()
  local member = selector:exec()
  if member and member:check_password(password) then
    return member
  else
    return nil
  end
end

function Member:by_login(login)
  local selector = self:new_selector()
  selector:add_where{'"login" = ?', login }
  selector:optional_object_mode()
  return selector:exec()
end

function Member:by_name(name)
  local selector = self:new_selector()
  selector:add_where{'"name" = ?', name }
  selector:optional_object_mode()
  return selector:exec()
end

function Member:get_search_selector(search_string)
  return self:new_selector()
    :add_field( {'"highlight"("member"."name", ?)', search_string }, "name_highlighted")
    :add_where{ '"member"."text_search_data" @@ "text_search_query"(?)', search_string }
    :add_where("active")
end

function Member.object:set_notify_email(notify_email)
  local expiry = db:query("SELECT now() + '7 days'::interval as expiry", "object").expiry
  self.notify_email_unconfirmed = notify_email
  self.notify_email_secret = multirand.string( 24, "23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz" )
  self.notify_email_secret_expiry = expiry
  local content = slot.use_temporary(function()
    slot.put(_"Hello " .. self.name .. ",\n\n")
    slot.put(_"Please confirm your email address by clicking the following link:\n\n")
    slot.put(config.absolute_base_url .. "index/confirm_notify_email.html?secret=" .. self.notify_email_secret .. "\n\n")
    slot.put(_"If this link is not working, please open following url in your web browser:\n\n")
    slot.put(config.absolute_base_url .. "index/confirm_notify_email.html\n\n")
    slot.put(_"On that page please enter the confirmation code:\n\n")
    slot.put(self.notify_email_secret .. "\n\n")
  end)
  local success = net.send_mail{
    envelope_from = config.mail_envelope_from,
    from          = config.mail_from,
    reply_to      = config.mail_reply_to,
    to            = self.notify_email_unconfirmed,
    subject       = config.mail_subject_prefix .. _"Email confirmation request",
    content_type  = "text/plain; charset=UTF-8",
    content       = content
  }
  return success
end

function Member.object:get_setting(key)
  return Setting:by_pk(app.session.member.id, key)
end

function Member.object:get_setting_value(key)
  local setting = Setting:by_pk(app.session.member.id, key)
  if setting then
    return setting.value
  end
end

function Member.object:set_setting(key, value)
  local setting = self:get_setting(key)
  if not setting then
    setting = Setting:new()
    setting.member_id = app.session.member_id
    setting.key = key
  end
  setting.value = value
  setting:save()
end

function Member.object:get_setting_maps_by_key(key)
  return SettingMap:new_selector()
    :add_where{ "member_id = ?", self.id }
    :add_where{ "key = ?", key }
    :add_order_by("subkey")
    :exec()
end

function Member.object:get_setting_map_by_key_and_subkey(key, subkey)
  return SettingMap:new_selector()
    :add_where{ "member_id = ?", self.id }
    :add_where{ "key = ?", key }
    :add_where{ "subkey = ?", subkey }
    :add_order_by("subkey")
    :optional_object_mode()
    :exec()
end

function Member.object:set_setting_map(key, subkey, value)
  
end
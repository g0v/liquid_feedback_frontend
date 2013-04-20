local login = param.get("login")
local password = param.get("password")

local member = Member:by_login_and_password(login, password)

function do_etherpad_auth(member)
  local result = net.curl(
    config.etherpad.api_base
    .. "api/1/createAuthorIfNotExistsFor?apikey=" .. config.etherpad.api_key
    .. "&name=" .. encode.url_part(member.name) .. "&authorMapper=" .. tostring(member.id)
  )

  if not result then
    slot.put_into("error", _"Etherpad authentication failed" .. " 1")
    return false
  end

  local etherpad_author_id = string.match(result, '"authorID"%s*:%s*"([^"]+)"')

  if not etherpad_author_id then
    slot.put_into("error", _"Etherpad authentication failed" .. " 2")
    return false
  end

  local time_in_24h = os.time() + 24 * 60 * 60

  local result = net.curl(
    config.etherpad.api_base
    .. "api/1/createSession?apikey=" .. config.etherpad.api_key
    .. "&groupID=" .. config.etherpad.group_id
    .. "&authorID=" .. etherpad_author_id
    .. "&validUntil=" .. time_in_24h
  )

  if not result then
    slot.put_into("error", _"Etherpad authentication failed" .. " 3")
    return false
  end

  local etherpad_sesion_id = string.match(result, '"sessionID"%s*:%s*"([^"]+)"')

  if not etherpad_sesion_id then
    slot.put_into("error", _"Etherpad authentication failed" .. " 4")
    return false
  end

  request.set_cookie{
    path = config.etherpad.cookie_path,
    name = "sessionID",
    value = etherpad_sesion_id
  }

end


if member and not member.locked and not member.locked_import then

  member.last_login = "now"
  member.last_activity = "now"
  member.active = true
  if member.lang == nil then
    member.lang = app.session.lang
  else
    app.session.lang = member.lang
  end

  if member.password_hash_needs_update then
    member:set_password(password)
  end

  member:save()

  app.session.member = member
  app.session:save()

  slot.put_into("notice", _"Login successful")

  trace.debug('User authenticated')

  if config.etherpad then
    do_etherpad_auth(member)
  end

elseif member and config.inform_locked_member then

  slot.put_into("error", _("Sorry, but your account is locked. To get unlocked please contact #{support}!", { support = '<a href="mailto:' .. config.support .. '">' .. config.support .. '</a>' }))
  trace.debug('User locked')

else

  slot.put_into("error", _"Invalid login name or password!")
  trace.debug('User NOT authenticated')

end

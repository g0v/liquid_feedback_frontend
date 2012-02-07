local member = Member:by_login_and_password(param.get('login'), param.get('password'))

if member then
  member.last_login = "now"
  member.last_activity = "now"
  member.active = true
  member:save()
  app.session.member = member
  app.session:save()
  slot.select("notice", function()
    ui.tag{ content = _'Login successful!' }
  end)
  trace.debug('User authenticated')
else
  slot.select("error", function()
    ui.tag{ content = _'Invalid username or password!' }
  end)
  trace.debug('User NOT authenticated')
  return false
end

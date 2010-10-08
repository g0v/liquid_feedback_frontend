local member = Member:by_login_and_password(param.get('login'), param.get('password'))

if member then
  app.session.member = member
  db:query{ "UPDATE member SET last_login = now() WHERE id = ?", member.id }
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

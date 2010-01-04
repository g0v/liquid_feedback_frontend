if request.get_module() == "admin" and not app.session.member.admin then
  error('access denied')
end

execute.inner()

if cgi.cookies.liquid_feedback_session then
  app.session = Session:by_ident(cgi.cookies.liquid_feedback_session)
end
if not app.session then
  app.session = Session:new()
  request.set_cookie{
    name = "liquid_feedback_session",
    value = app.session.ident
  }
end

request.set_csrf_secret(app.session.additional_secret)

if not app.session.member.lang then
  app.session.member.lang = app.session.lang or config.default_lang or "en"
  app.session.member:save()
end

locale.set{lang = app.session.member.lang }

execute.inner()

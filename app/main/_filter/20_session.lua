if cgi.cookies.liquid_feedback_session then
  app.session = Session:by_ident(cgi.cookies.liquid_feedback_session)
end
if not app.session then
  app.session = Session:new()
  cgi.add_header('Set-Cookie: liquid_feedback_session=' .. app.session.ident .. '; path=/' )
end

request.set_csrf_secret(app.session.additional_secret)

locale.set{lang = app.session.lang or "en"}

execute.inner()

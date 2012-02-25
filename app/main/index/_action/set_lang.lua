local lang = param.get("lang")
if lang == "de" or lang == "en" or lang == "eo" then
  app.session.lang = param.get("lang")
  app.session:save()
  if app.session.member then
    app.session.member.lang = app.session.lang
    app.session.member:save()
  end
end
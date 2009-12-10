local lang = param.get("lang")
if lang == "de" or lang == "en" then
  app.session.lang = param.get("lang")
  app.session:save()
end
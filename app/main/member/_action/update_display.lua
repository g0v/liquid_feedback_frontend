app.session.member:set_setting("tab_mode", param.get("tab_mode"))
app.session.member:set_setting("initiatives_preview_limit", param.get("initiatives_preview_limit", atom.number))

slot.put_into("notice", _"Your display settings have been updated")
param.update(app.session.member, "name")

app.session.member:save()


slot.put_into("notice", _"Your page has been updated")
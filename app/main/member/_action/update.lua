param.update(app.session.member,
  "organizational_unit",
  "internal_posts",
  "realname",
  "birthday",
  "address",
  "email",
  "xmpp_address",
  "website",
  "phone",
  "mobile_phone",
  "profession",
  "external_memberships",
  "external_posts",
  "statement"
)

if tostring(app.session.member.birthday) == "invalid_date" then
  app.session.member.birthday = nil
  slot.put_into("error", _"Date format is not valid. Please use following format: YYYY-MM-DD")
  return false
end

app.session.member:save()


slot.put_into("notice", _"Your page has been updated")
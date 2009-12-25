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

app.session.member:save()


slot.put_into("notice", _"Your page has been updated")
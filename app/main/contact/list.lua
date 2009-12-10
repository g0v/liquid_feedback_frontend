slot.put_into("title", _"Contacts")

util.help("contact.list")

execute.view{
  module = "contact",
  view = "_list",
  params = { contacts_selector = app.session.member:get_reference_selector("contacts") }
}

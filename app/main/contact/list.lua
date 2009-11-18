slot.put_into("title", _"Contacts")

execute.view{
  module = "contact",
  view = "_list",
  params = { contacts_selector = app.session.member:get_reference_selector("contacts") }
}

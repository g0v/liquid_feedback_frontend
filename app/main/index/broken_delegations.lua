ui.title(_"Broken delegations")

local delegations_selector = Member:selector_delegations()
  :add_where{ "member.id = ?", app.session.member_id }
  :add_where("trustee.active = FALSE")

execute.view{
  module = "delegation",
  view = "_list",
  params = {
    delegations_selector = delegations_selector,
    outgoing = true
  }
}

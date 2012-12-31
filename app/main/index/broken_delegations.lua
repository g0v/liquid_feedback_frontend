ui.title(_"Broken delegations")

local delegations_selector = Member:selector_delegations()
  :add_where{ "member.id = ?", app.session.member_id }
  :add_where{ "trustee.active = FALSE OR (trustee.last_activity IS NULL OR age(trustee.last_activity) > ?::interval)", config.delegation_warning_time }

execute.view{
  module = "delegation",
  view = "_list",
  params = {
    delegations_selector = delegations_selector,
    outgoing = true
  }
}

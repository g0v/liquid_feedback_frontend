ui.title(_"Expired and soon expiring delegations")
util.help("index.expiring_delegations")

local delegations_selector = Member:selector_delegations(true)
  :left_join("system_setting", nil, "TRUE")
  :add_where{ "member.id = ?", app.session.member_id }
  :add_where("delegation.issue_id ISNULL")
  :add_where{
    "delegation.active = FALSE OR delegation.confirmed < (CURRENT_DATE - (system_setting.delegation_ttl - ?::interval))::DATE",
    config.delegation_warning_time
  }

execute.view{
  module = "delegation",
  view = "_list",
  params = {
    delegations_selector = delegations_selector,
    outgoing = true
  }
}

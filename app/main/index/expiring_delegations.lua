ui.title(_"Expired and soon expiring delegations")
util.help("index.expiring_delegations")

local subselector = Member:selector_delegations(true)
  :add_distinct_on("delegation.unit_id, delegation.area_id, delegation.issue_id")
  :add_order_by("delegation.unit_id, delegation.area_id, delegation.issue_id")
  :add_field("delegation.confirmed")
  :left_join("system_setting", nil, "TRUE")
  :add_where{ "member.id = ?", app.session.member_id }
  :add_where("delegation.issue_id ISNULL")
  :add_where{
    "delegation.active = FALSE OR delegation.confirmed < (CURRENT_DATE - (system_setting.delegation_ttl - ?::interval))::DATE",
    config.delegation_warning_time
  }

-- order using a subquery, because order_by is already used by distinct_on
local delegations_selector = Member:get_db_conn():new_selector()
  :add_from(subselector)
  :add_field("*")
  :add_order_by("confirmed, scope_unit_name, scope_area_name, issue_id")

execute.view{
  module = "delegation",
  view = "_list",
  params = {
    delegations_selector = delegations_selector,
    outgoing = true
  }
}

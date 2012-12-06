local issue = Issue:by_id(param.get("issue_id", atom.integer))
local member = Member:by_id(param.get("member_id", atom.integer))

local members_selector = Member:new_selector()
  :join("delegating_population_snapshot", nil, "delegating_population_snapshot.member_id = member.id")
  :join("issue", nil, "issue.id = delegating_population_snapshot.issue_id")
  :add_where{ "delegating_population_snapshot.issue_id = ?", issue.id }
  :add_where{ "delegating_population_snapshot.event = ?", issue.latest_snapshot_event }
  :add_where{ "delegating_population_snapshot.delegate_member_id = ?", member.id }

ui.title(function()
  ui.link{
    content = issue.area.unit.name,
    module = "unit",
    view = "show",
    id = issue.area.unit.id
  }
  slot.put(" &middot; ")
  ui.link{
    content = issue.area.name,
    module = "area",
    view = "show",
    id = issue.area.id
  }
  slot.put(" &middot; ")
  ui.link{
    content = _("Issue ##{id}", { id = issue.id }),
    module = "issue",
    view = "show",
    id = issue.id
  }
  slot.put(" &middot; ")
  if member.id == app.session.member.id then
    -- show own delegation
    slot.put(_("Incoming delegations"))
  else
    -- show other member's delegation
    slot.put(_("Incoming delegations of member '#{member}'", { member = string.format('<a href="%s">%s</a>',
      encode.url{ module = "member", view = "show", id = member.id },
      encode.html(member.name)
    )}))
  end
end)

execute.view{
  module = "member",
  view = "_list",
  params = {
    members_selector = members_selector,
    issue = issue,
    trustee = member,
    show_delegation_link = true,
    population = true
  }
}
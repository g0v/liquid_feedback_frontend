local unit_id = config.single_unit_id or param.get_id()

local unit = Unit:by_id(unit_id)

if not config.single_unit_id then
  slot.put_into("title", unit.name)
else
  slot.put_into("title", encode.html(config.app_title))
end

if config.single_unit_id and not app.session.member_id and config.motd_public then
  local help_text = config.motd_public
  ui.container{
    attr = { class = "wiki motd" },
    content = function()
      slot.put(format.wiki_text(help_text))
    end
  }
end

util.help("unit.show", _"Unit")

if app.session.member_id then
  execute.view{
    module = "delegation",
    view = "_show_box",
    params = { unit_id = unit_id }
  }
end


local areas_selector = Area:build_selector{ active = true, unit_id = unit_id }
areas_selector:add_order_by("member_weight DESC")

local members_selector = Member:build_selector{
  active = true,
  voting_right_for_unit_id = unit.id
}

local delegations_selector = Delegation:new_selector()
  :join("member", "truster", "truster.id = delegation.truster_id AND truster.active")
  :join("privilege", "truster_privilege", "truster_privilege.member_id = truster.id AND truster_privilege.voting_right")
  :join("member", "trustee", "trustee.id = delegation.trustee_id AND truster.active")
  :join("privilege", "trustee_privilege", "trustee_privilege.member_id = trustee.id AND trustee_privilege.voting_right")
  :add_where{ "delegation.unit_id = ?", unit.id }

local issues_selector = Issue:new_selector()
  :join("area", nil, "area.id = issue.area_id")
  :add_where{ "area.unit_id = ?", unit.id }
  

local tabs = {
  module = "unit",
  view = "show",
  id = unit.id
}

tabs[#tabs+1] = {
  name = "areas",
  label = _"Areas",
  module = "area",
  view = "_list",
  params = { areas_selector = areas_selector }
}

tabs[#tabs+1] = {
  name = "issues",
  label = _"Issues",
  module = "issue",
  view = "_list",
  params = { issues_selector = issues_selector }
}

if app.session.member_id then
  tabs[#tabs+1] = {
    name = "members",
    label = _"Members",
    module = "member",
    view = "_list",
    params = { members_selector = members_selector }
  }

  tabs[#tabs+1] = {
    name = "delegations",
    label = _"Delegations",
    module = "delegation",
    view = "_list",
    params = { delegations_selector = delegations_selector }
  }
end

ui.tabs(tabs)
local voting_right_unit_id

local unit = Unit:by_id(param.get("unit_id", atom.integer))
if unit then
  voting_right_unit_id = unit.id
  slot.put_into("title", encode.html(config.single_unit_id and _"Set global delegation" or _"Set unit delegation"))
  util.help("delegation.new.unit")
end

local area = Area:by_id(param.get("area_id", atom.integer))
if area then
  voting_right_unit_id = area.unit_id
  slot.put_into("title", encode.html(_"Set delegation for Area '#{name}'":gsub("#{name}", area.name)))
  util.help("delegation.new.area")
end

local issue = Issue:by_id(param.get("issue_id", atom.integer))
if issue then
  voting_right_unit_id = issue.area.unit_id
  slot.put_into("title", encode.html(_"Set delegation for Issue ##{number} in Area '#{area_name}'":gsub("#{number}", issue.id):gsub("#{area_name}", issue.area.name)))
  util.help("delegation.new.issue")
end

local initiative = Initiative:by_id(param.get("initiative_id", atom.integer))

slot.select("actions", function()
  if issue then
    ui.link{
      module = "issue",
      view = "show",
      id = issue.id,
      content = function()
          ui.image{ static = "icons/16/cancel.png" }
          slot.put(_"Cancel")
      end,
    }
  elseif area then
    ui.link{
      module = "area",
      view = "show",
      id = area.id,
      content = function()
          ui.image{ static = "icons/16/cancel.png" }
          slot.put(_"Cancel")
      end,
    }
  else
    ui.link{
      module = "index",
      view = "index",
      content = function()
          ui.image{ static = "icons/16/cancel.png" }
          slot.put(_"Cancel")
      end,
    }
  end
end)


local contact_members = Member:build_selector{
  is_contact_of_member_id = app.session.member_id,
  voting_right_for_unit_id = voting_right_unit_id,
  order = "name"
}:exec()

ui.form{
  attr = { class = "vertical" },
  module = "delegation",
  action = "update",
  params = {
    unit_id = unit and unit.id or nil,
    area_id = area and area.id or nil,
    issue_id = issue and issue.id or nil,
  },
  routing = {
    default = {
      mode = "redirect",
      module = area and "area" or issue and "issue" or "unit",
      view = "show",
      id = area and area.id or issue and issue.id or unit.id
    }
  },
  content = function()
    local records

    if issue then
      local delegate_name = ""
      local scope = "no delegation set"
      local area_delegation = Delegation:by_pk(app.session.member_id, nil, issue.area_id)
      if area_delegation then
        delegate_name = area_delegation.trustee and area_delegation.trustee.name or _"abandoned"
        scope = _"area"
      else
        local unit_delegation = Delegation:by_pk(app.session.member_id, issue.area.unit_id)
        if unit_delegation then
          delegate_name = unit_delegation.trustee.name
          scope = config.single_unit_id and _"global" or _"unit"
        end
      end
      local text_apply
      local text_abandon
      if config.single_unit_id then
        text_apply = _("Apply global or area delegation for this issue (Currently: #{delegate_name} [#{scope}])", { delegate_name = delegate_name, scope = scope })
        text_abandon = _"Abandon unit and area delegations for this issue"
      else
        text_apply = _("Apply unit or area delegation for this issue (Currently: #{delegate_name} [#{scope}])", { delegate_name = delegate_name, scope = scope })
        text_abandon = _"Abandon unit and area delegations for this issue"
      end
      records = {
        { id = -1, name = text_apply },
        { id = 0,  name = text_abandon }
      }
    elseif area then
      local delegate_name = ""
      local scope = "no delegation set"
      local unit_delegation = Delegation:by_pk(app.session.member_id, area.unit_id)
      if unit_delegation then
        delegate_name = unit_delegation.trustee.name
        scope = config.single_unit_id and _"global" or _"unit"
      end
      local text_apply
      local text_abandon
      if config.single_unit_id then
        text_apply = _("Apply global delegation for this area (Currently: #{delegate_name} [#{scope}])", { delegate_name = delegate_name, scope = scope })
        text_abandon = _"Abandon global delegation for this area"
      else
        text_apply = _("Apply unit delegation for this area (Currently: #{delegate_name} [#{scope}])", { delegate_name = delegate_name, scope = scope })
        text_abandon = _"Abandon unit delegation for this area"
      end
      records = {
        {
          id = -1,
          name = text_apply
        },
        {
          id = 0,
          name = text_abandon
        }
      }

    else
      records = {
        {
          id = -1,
          name = _"No delegation"
        }
      }

    end
    -- add saved members
    records[#records+1] = {id="_", name= "--- " .. _"Saved contacts" .. " ---"}
    for i, record in ipairs(contact_members) do
      records[#records+1] = record
    end
    -- add initiative authors
    if initiative then
      records[#records+1] = {id="_", name= "--- " .. _"Initiators" .. " ---"}
      for i,record in ipairs(initiative.initiators) do
        records[#records+1] = record.member
      end
    end

    disabled_records = {}
    disabled_records["_"] = true

    ui.field.select{
      label = _"Trustee",
      name = "trustee_id",
      foreign_records = records,
      foreign_id = "id",
      foreign_name = "name",
      disabled_records = disabled_records
    }

    ui.submit{ text = _"Save" }
  end
}

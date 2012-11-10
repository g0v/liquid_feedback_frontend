-- show and edit the delegation


local voting_right_unit_id
local current_trustee_id
local current_trustee_name


local member_id = param.get("member_id", atom.integer)
if member_id == '' or member_id == app.session.member.id then
  -- show own delegation
  member = app.session.member
  ui_title = ""
else
  -- show other member's delegation
  member = Member:by_id(member_id)
  if not member or not member.activated then
    error("access denied")
  end
  ui_title = _("Member '#{member}'", { member =  member.name }) .. ": "
end


local unit = Unit:by_id(param.get("unit_id", atom.integer))
if unit then
  unit:load_delegation_info_once_for_member_id(member.id)
  voting_right_unit_id = unit.id
  if unit.delegation_info.own_delegation_scope == 'unit' then
    current_trustee_id = unit.delegation_info.first_trustee_id
    current_trustee_name = unit.delegation_info.first_trustee_name
  end
  ui.title(ui_title .. (config.single_unit_id and _"Global delegation" or _"Unit delegation"))
  util.help("delegation.new.unit")
end

local area = Area:by_id(param.get("area_id", atom.integer))
if area then
  area:load_delegation_info_once_for_member_id(member.id)
  voting_right_unit_id = area.unit_id
  if area.delegation_info.own_delegation_scope == 'area' then
    current_trustee_id = area.delegation_info.first_trustee_id
    current_trustee_name = area.delegation_info.first_trustee_name
  end
  ui.title(ui_title .. _("Delegation for Area '#{name}' in Unit '#{unit_name}'", { name = area.name, unit_name = area.unit.name }))
  util.help("delegation.new.area")
end

local issue = Issue:by_id(param.get("issue_id", atom.integer))
if issue then
  issue:load("member_info", { member_id = member.id })
  voting_right_unit_id = issue.area.unit_id
  if issue.member_info.own_delegation_scope == 'issue' then
    current_trustee_id = issue.member_info.first_trustee_id
    current_trustee_name = issue.member_info.first_trustee_name
  end
  ui.title(ui_title .. _("Delegation for Issue ##{number} in Area '#{area_name}' in Unit '#{unit_name}'", { number = issue.id, area_name = issue.area.name, unit_name = issue.area.unit.name }))
  util.help("delegation.new.issue")
end


-- check voting right of the trustee
if not member:has_voting_right_for_unit_id(voting_right_unit_id) then
  if member.id == app.session.member.id then
    slot.put_into("error", _"You have no voting right in this unit!")
  else
    slot.put_into("error", _"This member has no voting right in this unit!")
  end
  return
end


local delegation
local unit_id
local area_id
local issue_id
local initiative_id
local initiative

local scope = "unit"

unit_id = param.get("unit_id", atom.integer)

local inline = param.get("inline", atom.boolean)

if param.get("initiative_id", atom.integer) then
  initiative_id = param.get("initiative_id", atom.integer)
  initiative = Initiative:by_id(initiative_id)
  issue_id = initiative.issue_id
  scope = "issue"
end

if param.get("issue_id", atom.integer) then
  issue_id = param.get("issue_id", atom.integer)
  scope = "issue"
end

if param.get("area_id", atom.integer) then
  area_id = param.get("area_id", atom.integer)
  scope = "area"
end


-- link back
ui.actions(function()
  -- unserialize get-parameters
  local params = {}
  local param_get = param.get("back_params") or ""
  for key, value in string.gmatch(param_get, "([^=&]+)=([^=&]+)&") do
    params[key] = value
  end
  ui.link{
    module = param.get("back_module"),
    view = param.get("back_view"),
    id = param.get("back_id"),
    params = params,
    content = _"Back"
  }
end)


local delegations
local issue

if issue_id then
  issue = Issue:by_id(issue_id)
  delegations = Delegation:by_pk(member.id, nil, nil, issue_id)
  if not delegations then
    delegations = Delegation:by_pk(member.id, nil, issue.area_id)
  end
  if not delegations then
    delegations = Delegation:by_pk(member.id, issue.area.unit_id)
  end
elseif area_id then
  delegations = Delegation:by_pk(member.id, nil, area_id)
  if not delegations then
    local area = Area:by_id(area_id)
    delegations = Delegation:by_pk(member.id, area.unit_id)
  end
end

if not delegations then
  delegations = Delegation:by_pk(member.id, unit_id)
end

local preview_trustee_id = param.get("preview_trustee_id", atom.integer)


slot.put("<table border='0' width='100%'><tr><td width='50%' valign='top'>")

-- List of trustees

ui.heading{ level = 2, content = _"List of trustees" }
slot.put("<br />")

for i, delegation in ipairs(delegations) do

  ui.container{
    attr = { class = "delegation_form_row" },
    content = function()

      -- member thumb
      local trustee = Member:by_id(delegation.trustee_id)
      if not trustee:has_voting_right_for_unit_id(voting_right_unit_id) then
        trustee.member_valid = false
      end
      execute.view{
        module = "member",
        view = "_show_thumb",
        params = { member = trustee }
      }

      if member.id == app.session.member.id then

        if i ~= 1 then
          ui.form{
            attr = { class = "delegation_up" },
            module = "delegation",
            action = "update",
            params = {
              unit_id = unit and unit.id or nil,
              area_id = area and area.id or nil,
              issue_id = issue and issue.id or nil,
              initiative_id = initiative_id,
              trustee_id = delegation.trustee_id,
              trustee_swap_id = delegations[i-1].trustee_id
            },
            routing = {
              default = {
                mode = "redirect",
                module = request.get_module(),
                view = request.get_view(),
                id = param.get_id_cgi(),
                params = param.get_all_cgi()
              }
            },
            content = function()
              ui.tag{
                tag = "input",
                attr = {
                  class = "clickable",
                  type = "image",
                  src = encode.url{ static = "icons/move_up.png" },
                  name = _"up",
                  alt = _"up"
                }
              }
            end
          }
        end

        if i ~= #delegations then
          ui.form{
            attr = { class = "delegation_down" },
            module = "delegation",
            action = "update",
            params = {
              unit_id = unit and unit.id or nil,
              area_id = area and area.id or nil,
              issue_id = issue and issue.id or nil,
              initiative_id = initiative_id,
              trustee_id = delegation.trustee_id,
              trustee_swap_id = delegations[i+1].trustee_id
            },
            routing = {
              default = {
                mode = "redirect",
                module = request.get_module(),
                view = request.get_view(),
                id = param.get_id_cgi(),
                params = param.get_all_cgi()
              }
            },
            content = function()
              ui.tag{
                tag = "input",
                attr = {
                  class = "clickable",
                  type = "image",
                  src = encode.url{ static = "icons/move_down.png" },
                  name = _"down",
                  alt = _"down"
                }
              }
            end
          }
        end

        ui.form{
          attr = { class = "delegation_delete" },
          module = "delegation",
          action = "update",
          params = {
           unit_id = unit and unit.id or nil,
           area_id = area and area.id or nil,
           issue_id = issue and issue.id or nil,
           initiative_id = initiative_id,
           trustee_id = delegation.trustee_id,
           delete = true
          },
          routing = {
            default = {
              mode = "redirect",
              module = request.get_module(),
              view = request.get_view(),
              id = param.get_id_cgi(),
              params = param.get_all_cgi()
            },
          },
          content = function()
            ui.submit{ text = _"delete" }
          end
        }

      end

    end
  }

end


if #delegations == 0 then
  ui.tag{
    tag = "p",
    attr = { style = "font-style:italic" },
    content = _"There are no trustees selected."
  }
end


-- add trustee

if member.id == app.session.member.id then
  ui.form{
    attr = { class = "delegation_add" },
    module = "delegation",
    action = "update",
    params = {
      unit_id = unit and unit.id or nil,
      area_id = area and area.id or nil,
      issue_id = issue and issue.id or nil,
      initiative_id = initiative_id
    },
    routing = {
      default = {
        mode = "redirect",
        module = request.get_module(),
        view = request.get_view(),
        id = param.get_id_cgi(),
        params = param.get_all_cgi()
      }
    },
    content = function()

      -- collect contacts and initiators
      local records_initiators = {}
      local records_area       = {}
      local records_contacts   = {}
      local contact_selector = Member:new_selector()
      contact_selector:add_where("member.active = TRUE")
      contact_selector:join("privilege", nil, { "member.id = privilege.member_id AND privilege.voting_right AND privilege.unit_id = ?", voting_right_unit_id })
      contact_selector:left_join("contact", nil, "member.id = contact.other_member_id")
      if issue then
        contact_selector:left_join("membership", nil, { "member.id = membership.member_id AND membership.area_id = ?", issue.area_id })
        contact_selector:add_field("membership.member_id NOTNULL", "is_area_member")
        contact_selector:left_join("initiator", nil, "initiator.member_id = member.id")
        contact_selector:left_join("initiative", nil, { "initiative.id = initiator.initiative_id AND initiative.issue_id = ?", issue_id })
        contact_selector:add_field("initiative.id NOTNULL", "is_initiator")
        contact_selector:add_where{ "contact.member_id = ? OR initiative.id NOTNULL", member.id }
        contact_selector:add_group_by("member.id, membership.member_id, initiative.id")
      elseif area then
        contact_selector:left_join("membership", nil, { "member.id = membership.member_id AND membership.area_id = ?", area_id })
        contact_selector:add_field("membership.member_id NOTNULL", "is_area_member")
        contact_selector:add_where{ "contact.member_id = ?", member.id }
      else
        contact_selector:add_where{ "contact.member_id = ?", member.id }
      end
      contact_selector:add_order_by("member.name")
      local contact_members = contact_selector:exec()
      for i, record in ipairs(contact_members) do
        if issue and record.is_initiator then
          records_initiators[#records_initiators+1] = record
        elseif record.is_area_member then
          records_area[#records_area+1] = record
        else
          records_contacts[#records_contacts+1] = record
        end
      end

      -- join sections
      local records = {}
      if #records_initiators > 0 then
        records[#records+1] = {id="_", name= "--- " .. _"Initiators" .. " ---"}
        for i, record in ipairs(records_initiators) do
          records[#records+1] = record
        end
      end
      if #records_area > 0 then
        records[#records+1] = {id="_", name= "--- " .. _"Contacts participating in this area" .. " ---"}
        for i, record in ipairs(records_area) do
          records[#records+1] = record
        end
      end
      if #records_contacts > 0 then
        if #records_area > 0 then
          records[#records+1] = {id="_", name= "--- " .. _"Remaining contacts" .. " ---"}
        else
          records[#records+1] = {id="_", name= "--- " .. _"Contacts" .. " ---"}
        end
        for i, record in ipairs(records_contacts) do
          records[#records+1] = record
        end
      end

      local disabled_records = {}
      disabled_records["_"] = true
      disabled_records[app.session.member.id] = true

      -- check if there are members available to select
      local empty = true
      for i, value in ipairs(records) do
        if not disabled_records[value.id] then
          empty = false
          break
        end
      end
      if empty then
        ui.tag{
          tag = "p",
          attr = { style = "font-style:italic" },
          content = _"Your contact list is empty. To add members to this list of trustees, you have to add them to your contacts first."
        }
      else

        -- disable members which are already in the list of trustees
        for i, delegation in ipairs(delegations) do
          disabled_records[delegation.trustee_id] = true
        end

        -- check if there are members available to select
        local already_selected = true
        for i, value in ipairs(records) do
          if not disabled_records[value.id] then
            already_selected = false
            break
          end
        end
        if already_selected then
          ui.tag{
            tag = "p",
            attr = { style = "font-style:italic" },
            content = _"All your contacts are on this list of trustees. To add more members, you have to add them to your contacts first."
          }
        else

          ui.field.select{
            name = "trustee_id",
            foreign_records = records,
            foreign_id = "id",
            foreign_name = "name",
            disabled_records = disabled_records
          }
          ui.submit{ text = _"Add to list" }

        end

      end

      ui.field.hidden{ name = "preview" }

    end
  }
end


slot.put("</td><td width='50%' valign='top'>")

-- ------------------------

ui.heading{ level = 2, content = _"Complete preference list over all scopes" }
slot.put("<br />")

local delegation_chain = Member:new_selector()
  :add_field("delegation_chain.*")
  :join({ "delegation_chain(?,?,?,?,TRUE)", member.id, unit_id, area_id, issue_id }, "delegation_chain", "member.id = delegation_chain.member_id")
  :add_order_by("index")
  :exec()

for i, record in ipairs(delegation_chain) do
  local style
  local overridden = (not issue or issue.state ~= 'voting') and record.overridden

  -- arrow
  if i == 2 then
    ui.image{
      attr = {
        class = "delegation_arrow" .. (overridden and " overridden" or ""),
        alt = _"delegates to"
      },
      static = "delegation_arrow_24_vertical.png"
    }
    slot.put("<br>")
  end

  -- scope
  if record.scope_out ~= record.scope_in then
    ui.tag{
      attr = { class = "delegation_scope" .. (overridden and " scope_overridden" or "") },
      content = function()
        if record.scope_out == "unit" then
          slot.put(config.single_object_mode and _"Global delegation" or _"Unit delegation")
        elseif record.scope_out == "area" then
          slot.put(_"Area delegation")
        elseif record.scope_out == "issue" then
          slot.put(_"Issue delegation")
        end
      end
    }
  end

  -- delegation
  local class = "delegation_list_row"
  if overridden then
    class = class .. " overridden"
  elseif record.participation then
    class = class .. " delegation_highlighted"
  end
  ui.container{
    attr = { class = class },
    content = function()
      execute.view{
        module = "member",
        view = "_show_thumb",
        params = { member = record }
      }
      if not overridden and record.participation then
        ui.container{
          attr = { class = "delegation_participation" },
          content = function()
            slot.put(_"This member is participating, the rest of delegation list is suspended while discussing.")
          end
        }
      end
    end
  }

end

slot.put("</td></tr></table>")


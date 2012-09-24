-- show and edit the delegation


local voting_right_unit_id
local current_trustee_id
local current_trustee_name

local unit = Unit:by_id(param.get("unit_id", atom.integer))
if unit then
  unit:load_delegation_info_once_for_member_id(app.session.member_id)
  voting_right_unit_id = unit.id
  if unit.delegation_info.own_delegation_scope == 'unit' then
    current_trustee_id = unit.delegation_info.first_trustee_id
    current_trustee_name = unit.delegation_info.first_trustee_name
  end
  ui.title(config.single_unit_id and _"Set global delegation" or _"Set unit delegation")
  util.help("delegation.new.unit")
end

local area = Area:by_id(param.get("area_id", atom.integer))
if area then
  area:load_delegation_info_once_for_member_id(app.session.member_id)
  voting_right_unit_id = area.unit_id
  if area.delegation_info.own_delegation_scope == 'area' then
    current_trustee_id = area.delegation_info.first_trustee_id
    current_trustee_name = area.delegation_info.first_trustee_name
  end
  ui.title(_"Set delegation for Area '#{name}'":gsub("#{name}", area.name))
  util.help("delegation.new.area")
end

local issue = Issue:by_id(param.get("issue_id", atom.integer))
if issue then
  issue:load("member_info", { member_id = app.session.member_id })
  voting_right_unit_id = issue.area.unit_id
  if issue.member_info.own_delegation_scope == 'issue' then
    current_trustee_id = issue.member_info.first_trustee_id
    current_trustee_name = issue.member_info.first_trustee_name
  end
  ui.title(_"Set delegation for Issue ##{number} in Area '#{area_name}'":gsub("#{number}", issue.id):gsub("#{area_name}", issue.area.name))
  util.help("delegation.new.issue")
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
  ui.link{
    module = param.get("back_module"),
    view = param.get("back_view"),
    id = param.get("back_id"),
    content = _"Back"
  }
end)


local delegations
local issue

if issue_id then
  issue = Issue:by_id(issue_id)
  delegations = Delegation:by_pk(app.session.member.id, nil, nil, issue_id)
  if not delegations then
    delegations = Delegation:by_pk(app.session.member.id, nil, issue.area_id)
  end
  if not delegations then
    delegations = Delegation:by_pk(app.session.member.id, issue.area.unit_id)
  end
elseif area_id then
  delegations = Delegation:by_pk(app.session.member.id, nil, area_id)
  if not delegations then
    local area = Area:by_id(area_id)
    delegations = Delegation:by_pk(app.session.member.id, area.unit_id)
  end
end

if not delegations then
  delegations = Delegation:by_pk(app.session.member.id, unit_id)
end

local contact_members = Member:build_selector{
  is_contact_of_member_id = app.session.member_id,
  voting_right_for_unit_id = voting_right_unit_id,
  active = true,
  order = "name"
}:exec()

local preview_trustee_id = param.get("preview_trustee_id", atom.integer)


slot.put("<table border='0' width='100%'><tr><td width='50%' valign='top'>")

-- List of trustees

ui.heading{ level = 2, content = _"List of trustees" }

for i, delegation in ipairs(delegations) do
      
  execute.view{
    module = "member",
    view = "_show_thumb",
    params = { member = Member:by_id(delegation.trustee_id) }
  }
      
  ui.container{
    attr = { class = "delegation_action" },
    content = function()
     
      if i ~= 1 then
        ui.link{
          text   = _"up",
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
          }
        }
        slot.put("&nbsp;&nbsp;&nbsp;")
      end
      if i ~= #delegations then
        ui.link{
          text   = _"down",
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
          }
        }     
        slot.put("&nbsp;&nbsp;&nbsp;")
      end 
      ui.link{
        text   = _"delete",
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
          }
        }
      }
      
    end
  }
            
  slot.put("<br style='clear: left'/>")
end    


-- add trustee

ui.form{
  attr = { class = "vertical", id = "delegationForm" },
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
   
    local records
    records = {}
  
    -- add initiative authors
    if initiative then
      records[#records+1] = {id="_", name= "--- " .. _"Initiators" .. " ---"}
      for i,record in ipairs(initiative.initiators) do
        records[#records+1] = record.member
      end
    end
    -- add saved members
    if #contact_members > 0 then
      records[#records+1] = {id="_", name= "--- " .. _"Saved contacts" .. " ---"}
      for i, record in ipairs(contact_members) do
        records[#records+1] = record
      end
    end
    
    disabled_records = {}
    disabled_records["_"] = true
    disabled_records[app.session.member_id] = true
    -- disable members which are already in the list of trustees
    for i, delegation in ipairs(delegations) do
      disabled_records[delegation.trustee_id] = true
    end
    
    ui.field.select{
      name = "trustee_id",
      foreign_records = records,
      foreign_id = "id",
      foreign_name = "name",
      disabled_records = disabled_records
    }
    ui.submit{ text = _"Add to list" }

    ui.field.hidden{ name = "preview" }
    
  end
}


slot.put("</td><td width='50%' valign='top'>")

-- ------------------------

--slot.put("<hr>")
ui.heading{ level = 2, content = _"Complete preference list over all scopes" }

local delegation_chain = Member:new_selector()
  :add_field("delegation_chain.*")
  :join({ "delegation_chain(?,?,?,?,TRUE)", app.session.member.id, unit_id, area_id, issue_id }, "delegation_chain", "member.id = delegation_chain.member_id")
  :add_order_by("index")
  :exec()

for i, record in ipairs(delegation_chain) do
  local style
  local overridden = (not issue or issue.state ~= 'voting') and record.overridden
  
  if i == 2 then
    if not overridden then
      ui.image{
        attr = { class = "delegation_arrow" },
        static = "delegation_arrow_24_vertical.png"
      }
    else
      ui.image{
        attr = { class = "delegation_arrow delegation_arrow_overridden" },
        static = "delegation_arrow_24_vertical.png"
      }
    end
    slot.put("<br>")
  end

  if record.scope_out ~= record.scope_in then
    ui.tag{
      attr = { class = "delegation_scope" .. (overridden and " delegation_scope_overridden" or "") },
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
  
  ui.container{
    attr = { class = overridden and "delegation_overridden" or "" },
    content = function()
      execute.view{
        module = "member",
        view = "_show_thumb",
        params = { member = record }
      }
    end
  }
  
  if (not issue or issue.state ~= 'voting') and record.participation and not record.overridden then
    ui.container{
      attr = { class = "delegation_participation" },
      content = function()
        slot.put(_"This member is participating, the rest of delegation chain is suspended while discussing")
      end
    }
  end
  
  slot.put("<br style='clear: left'/>")
end

slot.put("</td></tr></table>")


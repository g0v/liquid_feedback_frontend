-- displays the small delegation chain in the right top corner


-- show delegation information only for logged in members
if not app.session.member_id then
  return
end


local member = param.get("member", "table") or app.session.member

local unit  = param.get("unit", "table")
local area  = param.get("area", "table")
local issue = param.get("issue", "table")

local unit_id  = unit  and unit.id  or nil
local area_id  = area  and area.id  or nil
local issue_id = issue and issue.id or nil

-- title of the link to the delegation page
if issue then
  link_title = _"Issue delegation"
elseif area then
  link_title = _"Area delegation"
else
  link_title = config.single_object_mode and _"Global delegation" or _"Unit delegation"
end

-- serialize get-parameters
local params = ''
for key, value in pairs(param.get_all_cgi()) do
  params = params .. key .. "=" .. value .. "&"
end

ui.link{
  module = "delegation", view = "show", params = {
    unit_id = unit_id,
    area_id = area_id,
    issue_id = issue_id,
    member_id = member.id,
    back_module = request.get_module(),
    back_view = request.get_view(),
    back_id = param.get_id_cgi(),
    back_params = params
  },
  attr = { class = "delegation_info", title = link_title },
  content = function()

    local participant_occured = false
  
    -- configure how many delegates should be displayed
    local show_max_delegates = 15
   
    local delegation_chain = Member:new_selector()
      :add_field("delegation_chain.*")
      :join({ "delegation_chain(?,?,?,?,FALSE)", app.session.member.id, unit_id, area_id, issue_id }, "delegation_chain", "member.id = delegation_chain.member_id")
      :add_order_by("index")
      :limit(show_max_delegates + 2)
      :exec()
    
    for i, record in ipairs(delegation_chain) do
      
      if i == show_max_delegates + 2 then
        slot.put("...")
        break
      end
      
      local style
      --local overridden = (not issue or issue.state ~= 'voting') and record.overridden
  
      if i == 2 then      
        local text = _"delegates to"
        ui.image{
          attr = { class = "delegation_arrow", alt = text, title = text },
          static = "delegation_arrow_24_horizontal.png"
        }
      end
        
      -- highlight if participating 
      local class = "micro_avatar"
      if participant_occured and record.participation then
        participant_occured = true
        class = class .. " highlighted"
      end
        
      -- get name of member
      local member = Member:by_id(record.member_id)
        
      execute.view{
        module = "member_image",
        view = "_show",
        params = {
          member_id = record.member_id,
          class = class,
          popup_text = member.name,
          image_type = "avatar",
          show_dummy = true
        }
      }
   
    end

  end
}

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

-- user without voting right also have no delegations
local voting_right_unit_id
if unit then
  voting_right_unit_id = unit.id
elseif area then
  voting_right_unit_id = area.unit_id
elseif issue then
  voting_right_unit_id = issue.area.unit_id
end
if not member:has_voting_right_for_unit_id(voting_right_unit_id) then
  return
end

-- title of the link to the delegation page
local scope
if issue then
  link_title = _"Issue delegation"
  scope = "issue"
elseif area then
  link_title = _"Area delegation"
  scope = "area"
else
  link_title = config.single_object_mode and _"Global delegation" or _"Unit delegation"
  scope = "unit"
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

    -- configure how many members should be displayed
    local show_max = 16

    local delegation_chain = Member:new_selector()
      :add_field("delegation_chain.*")
      :join(
        { "delegation_chain(?,?,?,?,TRUE)", member.id, unit_id, area_id, issue_id },
        "delegation_chain",
        "member.id = delegation_chain.member_id"
      )
      :add_order_by("index")
      :exec()

    slot.put('<div class="delegation_info_none">')
    local dots_displayed = false

    local no_participation = true
    for i, record in ipairs(delegation_chain) do
      if record.participation then
        no_participation = false
        break
      end
    end

    for i, record in ipairs(delegation_chain) do

      local overridden = (not issue or issue.state ~= 'voting') and record.overridden

      if i >= 2 then

        -- show all of the same scope and further until the particicating member
        if record.scope_out ~= scope and (overridden or no_participation) then
          break
        end

        if i == 2 then
          ui.image{
            attr = { class = "delegation_arrow", alt = _"delegates to" },
            static = "delegation_arrow_24_horizontal.png"
          }
        end

        -- separate scopes
        if record.scope_out ~= record.scope_in and record.scope_out ~= scope then
          slot.put('</div><div class="delegation_info_' .. record.scope_out .. '">')
          dots_displayed = false
        end

      end

      -- show only the first members and the participating one; replace the rest by dots
      if i <= show_max or record.participation then

        -- name of member
        local member = Member:by_id(record.member_id)
        local popup_text = link_title .. ": " .. member.name

        -- highlight if participating
        local class = "micro_avatar"
        if not overridden and record.participation then
          class = class .. " highlighted"
          popup_text = popup_text .. " - " .. _"This member is participating."
        end

        execute.view{
          module = "member_image",
          view = "_show",
          params = {
            member_id = record.member_id,
            class = class,
            popup_text = popup_text,
            image_type = "avatar",
            show_dummy = true
          }
        }

        -- end after participating member
        if record.participation and i > show_max then
          break
        end

      elseif not dots_displayed then
        slot.put("...")
        dots_displayed = true
      end

    end

    slot.put('</div>')

  end
}

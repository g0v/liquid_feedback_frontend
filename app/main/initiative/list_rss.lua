if not config.feature_rss_enabled then
  error("feature not enabled")
end

local area_id = param.get("area_id", atom.integer)
local issue_id = param.get("issue_id", atom.integer)
local order = param.get("order") or "last_created"

local initiatives_selector = Initiative:new_selector()

local issue
local area

if issue_id then
  issue = Issue:by_id(issue_id)
  initiatives_selector:add_where{ "initiative.issue_id = ?", issue_id }
elseif area_id then
  area = Area:by_id(area_id)
  initiatives_selector:join("issue", nil, "issue.id = initiative.issue_id")
  initiatives_selector:add_where{ "issue.area_id = ?", area_id }
end


if order == "last_created" then
  initiatives_selector:add_order_by("initiative.created DESC")
  initiatives_selector:add_field("initiative.created", "created_or_updated")
elseif order == "last_updated" then
  initiatives_selector:add_field("(SELECT MAX(created) FROM draft WHERE initiative_id = initiative.id GROUP BY initiative_id)", "created_or_updated")
  initiatives_selector:add_order_by("(SELECT MAX(created) FROM draft WHERE initiative_id = initiative.id GROUP BY initiative_id) DESC")
else
  error("Invalid order")
end

initiatives_selector:add_order_by("id DESC")

initiatives_selector:limit(25)

local initiatives = initiatives_selector:exec()

slot.set_layout("atom")
request.force_absolute_baseurl()

ui.tag{
  tag = "author",
  content = function()
    ui.tag{
      tag = "name",
      content = "LiquidFeedback"
    }
  end
}

local title

if issue then
  title = "#" .. tostring(issue.id) .. " " .. issue.area.name
elseif area then
  title = area.name
else
  title = config.app_title
end

ui.tag{
  tag = "title",
  content = title
}

local subtitle
if order == "last_created" then
  subtitle = "Initiatives (last created first)"
elseif order == "last_updated" then
  subtitle = "Initiatives (last updated first)"
end

ui.tag{
  tag = "subtitle",
  content = subtitle
}

ui.tag{
  tag = "id",
--  content = "urn:uuid:60a76c80-d399-11d9-b93C-0003939e0af6"
}

--[[
ui.tag{
  tag = "updated",
  content = "2003-12-14T10:20:09Z"
}
--]]

for i, initiative in ipairs(initiatives) do
  ui.tag{
    tag = "entry",
    content = function()
      slot.put("\n")
      ui.tag{ tag = "category", attr = { term = encode.html(initiative.issue.area.name) } }
      slot.put("\n")
      ui.tag{ tag = "author", content = encode.html(initiative.current_draft.author.name) }
      slot.put("\n")
      ui.tag{ tag = "title", content = encode.html(initiative.shortened_name) }
      slot.put("\n")
      ui.tag{ tag = "link", attr = { 
        href = encode.url{
          module = "initiative",
          view = "show",
          id = initiative.id
        }
      } }
      slot.put("\n")
      ui.tag{ tag = "id",  content = "initiative_" .. tostring(initiative.id) }
      slot.put("\n")
      ui.tag{ tag = "updated",  content = tostring(initiative.created_or_updated) }
      slot.put("\n")
      ui.tag{ tag = "content",  content = encode.html(initiative.current_draft.content or "") }
      slot.put("\n")
    end
  }
  slot.put("\n")
end

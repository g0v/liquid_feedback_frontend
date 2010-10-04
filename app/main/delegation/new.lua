local area = Area:by_id(param.get("area_id", atom.integer))
if area then
  slot.put_into("title", encode.html(_"Set delegation for Area '#{name}'":gsub("#{name}", area.name)))
  util.help("delegation.new.area")
end

local issue = Issue:by_id(param.get("issue_id", atom.integer))
if issue then
  slot.put_into("title", encode.html(_"Set delegation for Issue ##{number} in Area '#{area_name}'":gsub("#{number}", issue.id):gsub("#{area_name}", issue.area.name)))
  util.help("delegation.new.issue")
end

local initiative = Initiative:by_id(param.get("initiative_id", atom.integer))

if not area and not issue then
  slot.put_into("title", encode.html(_"Set global delegation"))
  util.help("delegation.new.global")
end

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



local contact_members = Member:new_selector()
  :add_where{ "contact.member_id = ?", app.session.member.id }
  :join("contact", nil, "member.id = contact.other_member_id")
  :add_order_by("member.name")
  :exec()


ui.form{
  attr = { class = "vertical" },
  module = "delegation",
  action = "update",
  params = {
    area_id = area and area.id or nil,
    issue_id = issue and issue.id or nil,
  },
  routing = {
    default = {
      mode = "redirect",
      module = area and "area" or issue and "issue" or "index",
      view = (area or issue) and "show" or "index",
      id = area and area.id or issue and issue.id or nil,
    }
  },
  content = function()
    local records = {
      {
        id = "-1",
        name = _"No delegation"
      }
    }

    for i, record in ipairs(contact_members) do
      records[#records+1] = record
    end
    disabled_records = {}
    -- add initiative authors
    if initiative then
      records[#records+1] = {id="_", name=_"--- Initiators ---"}
      disabled_records["_"] = true
      for i,record in ipairs(initiative.initiators) do
        trace.debug(record)
        trace.debug(record.member.name)
        records[#records+1] = record.member
      end
    end

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

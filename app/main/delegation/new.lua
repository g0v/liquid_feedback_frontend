local area = Area:by_id(param.get("area_id", atom.integer))
if area then
  slot.put_into("title", encode.html(_"Set delegation for Area '#{name}'":gsub("#{name}", area.name)))
end

local issue = Issue:by_id(param.get("issue_id", atom.integer))
if issue then
  slot.put_into("title", encode.html(_"Set delegation for Issue ##{number} in Area '#{area_name}'":gsub("#{number}", issue.id):gsub("#{area_name}", issue.area.name)))
end


local contact_members = Member:new_selector()
  :add_where{ "contact.member_id = ?", app.session.member.id }
  :join("contact", nil, "member.id = contact.other_member_id")
  :add_order_by("member.login")
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
      module = area and "area" or "issue",
      view = "show",
      id = area and area.id or issue.id,
    }
  },
  content = function()
    ui.field.select{
      label = _"Trustee",
      name = "trustee_id",
      foreign_records = contact_members,
      foreign_id = "id",
      foreign_name = "name"
    }
    ui.submit{ text = _"Save" }
  end
}
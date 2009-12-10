local issue
local area

local issue_id = param.get("issue_id", atom.integer)
if issue_id then
  issue = Issue:new_selector():add_where{"id=?",issue_id}:single_object_mode():exec()
  area = issue.area

else
  local area_id = param.get("area_id", atom.integer)
  area = Area:new_selector():add_where{"id=?",area_id}:single_object_mode():exec()
end

if issue_id then
  slot.put_into("title", _"Add new initiative to issue")
else
  slot.put_into("title", _"Create new issue")
end

ui.form{
  module = "initiative",
  action = "create",
  params = {
    area_id = area.id,
    issue_id = issue and issue.id or nil
  },
  attr = { class = "vertical" },
  content = function()
    ui.field.text{ label = _"Area",  value = area.name }
    if issue_id then
      ui.field.text{ label = _"Issue",  value = issue_id }
    else
      ui.field.select{
        label = _"Policy",
        name = "policy_id",
        foreign_records = Policy:new_selector():exec(),
        foreign_id = "id",
        foreign_name = "name"
      }
    end
    ui.field.text{ label = _"Name", name = "name" }
    ui.field.text{ label = _"Discussion URL", name = "discussion_url" }
    ui.field.select{
      label = _"Wiki engine",
      name = "formatting_engine",
      foreign_records = {
        { id = "rocketwiki", name = "RocketWiki" },
        { id = "compat", name = _"Traditional wiki syntax" }
      },
      foreign_id = "id",
      foreign_name = "name"
    }
    ui.field.text{ label = _"Draft", name = "draft", multiline = true, attr = { style = "height: 50ex;" } }
    ui.submit{ text = _"Save" }
  end
}
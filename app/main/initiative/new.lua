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
  slot.put_into("title", _"Add alternative initiative to issue")
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
    slot.put("<br />")
    if issue_id then
      ui.field.text{ label = _"Issue",  value = issue_id }
    else
      tmp = { { id = -1, name = _"Please choose a policy" } }
      for i, allowed_policy in ipairs(area.allowed_policies) do
        tmp[#tmp+1] = allowed_policy
      end
      ui.field.select{
        label = _"Policy",
        name = "policy_id",
        foreign_records = tmp,
        foreign_id = "id",
        foreign_name = "name",
        value = (area.default_policy or {}).id
      }
    end
    ui.tag{
      tag = "div",
      content = function()
        ui.tag{
          tag = "label",
          attr = { class = "ui_field_label" },
          content = function() slot.put("&nbsp;") end,
        }
        ui.tag{
          content = function()
            ui.link{
              text = _"Information about the available policies",
              module = "policy",
              view = "list"
            }
            slot.put(" ")
            ui.link{
              attr = { target = "_blank" },
              text = _"(new window)",
              module = "policy",
              view = "list"
            }
          end
        }
      end
    }
    slot.put("<br />")
    ui.field.text{ label = _"Title of initiative", name = "name" }
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
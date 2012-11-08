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
  ui.title(_"Add alternative initiative to issue")
  ui.actions(function()
    ui.link{
      content = function()
        ui.image{ static = "icons/16/cancel.png" }
        slot.put(_"Cancel")
      end,
      module = "issue",
      view = "show",
      id = issue.id,
      params = { tab = "suggestions" }
    }
  end)
else
  ui.title(_"Create new issue")
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

    ui.field.text{ label = _"Unit",  value = area.unit.name }
    ui.field.text{ label = _"Area",  value = area.name }
    if issue_id then
      ui.field.text{
        label = _"Issue",
        value = _("#{policy_name} ##{issue_id}", { policy_name = issue.policy.name, issue_id = issue.id }),
        readonly = true
      }
    end
    slot.put("<br />")

    if param.get("preview") then

      ui.container{ attr = { class = "initiative_head" }, content = function()

        -- title
        ui.container{
          attr = { class = "title" },
          content = _"Initiative" .. ": " .. encode.html(param.get("name"))
        }

        -- draft content
        ui.container{
          attr = { class = "draft_content wiki" },
          content = function()
            slot.put(format.wiki_text(param.get("draft"), param.get("formatting_engine")))
          end
        }

      end }

      ui.submit{ text = _"Save" }
      slot.put("<br /><br /><br />")

    end

    if not issue_id then
      tmp = { { id = -1, name = _"Please choose a policy!" } }
      for i, allowed_policy in ipairs(area.allowed_policies) do
        tmp[#tmp+1] = allowed_policy
      end
      ui.field.select{
        label = _"Policy",
        name = "policy_id",
        foreign_records = tmp,
        foreign_id = "id",
        foreign_name = "name",
        value = param.get("policy_id", atom.integer) or area.default_policy and area.default_policy.id
      }
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
    end

    ui.field.text{
      label = _"Title of initiative",
      name  = "name",
      value = param.get("name")
    }
    ui.field.text{
      label = _"Discussion URL",
      name = "discussion_url",
      value = param.get("discussion_url")
    }

    ui.wikitextarea("draft", _"Content")

    ui.submit{ name = "preview", text = _"Preview" }
    -- hack for the additional submit button, because ui.submit does not allow to set the class attribute
    ui.tag{ tag = "input", attr = { type = "submit", class = "additional", value = _"Save" } }

  end
}
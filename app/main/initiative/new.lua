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
    ui.field.text{ label = _"Unit",  value = area.unit.name }
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
        value = area.default_policy and area.default_policy.id or param.get("policy_id", atom.integer)
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
    
    if param.get("preview") then
      ui.heading{ level = 1, content = encode.html(param.get("name")) }
      local discussion_url = param.get("discussion_url")
      ui.container{
        attr = { class = "ui_field_label" },
        content = _"Discussion with initiators"
      }
      ui.tag{
        tag = "span",
        content = function()
          if discussion_url:find("^https?://") then
            if discussion_url and #discussion_url > 0 then
              ui.link{
                attr = {
                  class = "actions",
                  target = "_blank",
                  title = discussion_url
                },
                content = discussion_url,
                external = discussion_url
              }
            end
          else
            slot.put(encode.html(discussion_url))
          end
        end
      }
      ui.container{
        attr = { class = "draft_content wiki" },
        content = function()
          slot.put(format.wiki_text(param.get("draft"), param.get("formatting_engine")))
        end
      }
      slot.put("<br />")
      ui.submit{ text = _"Save" }
      slot.put("<br />")
      slot.put("<br />")
    end
    slot.put("<br />")

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
    ui.field.select{
      label = _"Wiki engine",
      name = "formatting_engine",
      foreign_records = {
        { id = "rocketwiki", name = "RocketWiki" },
        { id = "compat", name = _"Traditional wiki syntax" }
      },
      attr = {id = "formatting_engine"},
      foreign_id = "id",
      foreign_name = "name",
      value = param.get("formatting_engine")
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
                text = _"Syntax help",
                module = "help",
                view = "show",
                id = "wikisyntax",
                attr = {onClick="this.href=this.href.replace(/wikisyntax[^.]*/g, 'wikisyntax_'+getElementById('formatting_engine').value)"}
              }
              slot.put(" ")
              ui.link{
                text = _"(new window)",
                module = "help",
                view = "show",
                id = "wikisyntax",
                attr = {target = "_blank", onClick="this.href=this.href.replace(/wikisyntax[^.]*/g, 'wikisyntax_'+getElementById('formatting_engine').value)"}
              }
            end
          }
        end
      }
    ui.field.text{
      label = _"Draft",
      name = "draft",
      multiline = true, 
      attr = { style = "height: 50ex;" },
      value = param.get("draft")
    }
    ui.submit{ name = "preview", text = _"Preview" }
    ui.submit{ text = _"Save" }
  end
}
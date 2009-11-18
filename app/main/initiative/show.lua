local initiative = Initiative:new_selector():add_where{ "id = ?", param.get_id()}:single_object_mode():exec()

slot.put_into("html_head", '<link rel="alternate" type="application/rss+xml" title="RSS" href="../show/' .. tostring(initiative.id) .. '.rss" />')

execute.view{
  module = "supporter",
  view = "_show_box",
  params = { initiative = initiative }
}

execute.view{
  module = "delegation",
  view = "_show_box",
  params = { issue_id = initiative.issue_id }
}


slot.select("path", function()
  ui.link{
    content = _"Area '#{name}'":gsub("#{name}", initiative.issue.area.name),
    module = "area",
    view = "show",
    id = initiative.issue.area.id
  }
  ui.container{ content = "::" }
  ui.link{
    content = _"Issue ##{id} (#{policy_name})":gsub("#{id}", initiative.issue.id):gsub("#{policy_name}", initiative.issue.policy.name),
    module = "issue",
    view = "show",
    id = initiative.issue.id
  }
end)

slot.put_into("title", encode.html(_"Initiative: '#{name}'":gsub("#{name}", initiative.shortened_name) ))

slot.select("actions", function()

  ui.twitter("http://example.com/i" .. tostring(initiative.id) .. " " .. initiative.name)

end)


ui.container{
  attr = {  id = "add_suggestion_form", class = "hidden_inline_form" },
  content = function()

    ui.link{
      content = _"Close",
      attr = {
        onclick = "document.getElementById('add_suggestion_form').style.display='none';return(false)",
        style = "float: right;"
      }
    }

    ui.field.text{ attr = { class = "head" }, value = _"Add new suggestion" }


    ui.form{
      module = "suggestion",
      action = "add",
      params = { initiative_id = initiative.id },
      routing = {
        default = {
          mode = "redirect",
          module = "initiative",
          view = "show",
          id = initiative.id,
          params = { tab = "suggestion" }
        }
      },
      attr = { class = "vertical" },
      content = function()
        ui.field.text{ label = _"Name",        name = "name" }
        ui.field.text{ label = _"Description", name = "description", multiline = true }
        ui.field.select{ 
          label = _"Degree", 
          name = "degree",
          foreign_records = { 
            { id =  1, name = _"should"},
            { id =  2, name = _"must"},
          },
          foreign_id = "id",
          foreign_name = "name"
        }
        ui.submit{ text = _"Commit suggestion" }
      end
    }
  end
}


ui.tabs{
  {
    name = "current_draft",
    label = _"Current draft",
    content = function()
      execute.view{ module = "draft", view = "_show", params = { draft = initiative.current_draft } }
      if Initiator:by_pk(initiative.id, app.session.member.id) then
        ui.link{
          content = function()
            ui.image{ static = "icons/16/script_add.png" }
            slot.put(_"Add new draft")
          end,
          module = "draft",
          view = "new",
          params = { initiative_id = initiative.id }
        }
      end
    end
  },
  {
    name = "details",
    label = _"Details",
    content = function()
      ui.form{
        attr = { class = "vertical" },
        record = initiative,
        readonly = true,
        content = function()
          ui.field.text{ label = _"Issue policy", value = initiative.issue.policy.name }
          ui.field.text{
            label = _"Created at",
            value = tostring(initiative.created)
          }
          ui.field.text{
            label = _"Created at",
            value = format.timestamp(initiative.created)
          }
          ui.field.date{ label = _"Revoked at", name = "revoked" }
          ui.field.boolean{ label = _"Admitted", name = "admitted" }
        end
      }
    end
  },
  {
    name = "suggestion",
    label = _"Suggestions",
    content = function()
      execute.view{ module = "suggestion", view = "_list", params = { suggestions_selector = initiative:get_reference_selector("suggestions") } }
      slot.put("<br />")
      if not initiative.issue.frozen and not initiative.issue.closed then
        ui.link{
          content = function()
            ui.image{ static = "icons/16/comment_add.png" }
            slot.put(_"Add new suggestion")
          end,
          attr = { onclick = "document.getElementById('add_suggestion_form').style.display='block';return(false)" },
          static = "#"
        }
      end
    end
  },
  {
    name = "supporter",
    label = _"Supporter",
    content = function()
      execute.view{ module = "member", view = "_list", params = { members_selector = initiative:get_reference_selector("supporting_members") } }
    end
  },
  {
    name = "initiators",
    label = _"Initiators",
    content = function()
      execute.view{ module = "member", view = "_list", params = { members_selector = initiative:get_reference_selector("initiating_members") } }
    end
  },
  {
    name = "drafts",
    label = _"Old drafts",
    content = function()
      execute.view{ module = "draft", view = "_list", params = { drafts = initiative.drafts } }
    end
  },
}



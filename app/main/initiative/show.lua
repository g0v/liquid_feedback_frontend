local initiative = Initiative:new_selector():add_where{ "id = ?", param.get_id()}:single_object_mode():exec()

--slot.put_into("html_head", '<link rel="alternate" type="application/rss+xml" title="RSS" href="../show/' .. tostring(initiative.id) .. '.rss" />')

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

execute.view{
  module = "issue",
  view = "_show_box",
  params = { issue = initiative.issue }
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
    content = _"Issue ##{id}":gsub("#{id}", initiative.issue.id),
    module = "issue",
    view = "show",
    id = initiative.issue.id
  }
end)

slot.put_into("title", encode.html(_"Initiative: '#{name}'":gsub("#{name}", initiative.shortened_name) ))

slot.select("actions", function()

  local initiator = Initiator:by_pk(initiative.id, app.session.member.id)

  if initiator then
    ui.link{
      content = function()
        ui.image{ static = "icons/16/script_add.png" }
        slot.put(_"Edit draft")
      end,
      module = "draft",
      view = "new",
      params = { initiative_id = initiative.id }
    }
  end

  if not initiative.issue.fully_frozen and not initiative.issue.closed then
    ui.link{
      attr = { class = "action" },
      content = function()
        ui.image{ static = "icons/16/script_add.png" }
        slot.put(_"Create alternative initiative" )
      end,
      module = "initiative",
      view = "new",
      params = { issue_id = initiative.issue.id }
    }
  end
--  ui.twitter("http://example.com/i" .. tostring(initiative.id) .. " " .. initiative.name)

  if initiative.discussion_url and #initiative.discussion_url > 0 then
    ui.link{
      attr = { 
        target = _"blank",
        title = initiative.discussion_url
      },
      content = function()
        ui.image{ static = "icons/16/comments.png" }
        slot.put(_"External discussion")
      end,
      external = initiative.discussion_url
    }
  end
  if initiator then
    ui.link{
      content = _"(change)",
      module = "initiative",
      view = "edit",
      id = initiative.id
    }
  end
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

local supporter = app.session.member:get_reference_selector("supporters")
  :add_where{ "initiative_id = ?", initiative.id }
  :optional_object_mode()
  :exec()

if supporter then
  local old_draft_id = supporter.draft_id
  local new_draft_id = initiative.current_draft.id
  if old_draft_id ~= new_draft_id then
    ui.container{
      attr = { class = "draft_updated_info" },
      content = function()
        slot.put("The draft of this initiative has been updated!")
        slot.put(" ")
        ui.link{
          content = _"Show diff",
          module = "draft",
          view = "diff",
          params = {
            old_draft_id = old_draft_id,
            new_draft_id = new_draft_id
          }
        }
        slot.put(" ")
        ui.link{
          content = _"Refresh support to current draft",
          module = "initiative",
          action = "add_support",
          id = initiative.id,
          routing = {
            default = {
              mode = "redirect",
              module = "initiative",
              view = "show",
              id = initiative.id
            }
          }
        }
      end
    }
  end
end

ui.tabs{
  {
    name = "current_draft",
    label = _"Current draft",
    content = function()
      execute.view{ module = "draft", view = "_show", params = { draft = initiative.current_draft } }
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
      execute.view{
        module = "member",
        view = "_list",
        params = {
          initiative = initiative,
          members_selector =  initiative:get_reference_selector("supporting_members_snapshot")
            :join("issue", nil, "issue.id = direct_supporter_snapshot.issue_id")
            :join("direct_population_snapshot", nil, "direct_population_snapshot.event = issue.latest_snapshot_event AND direct_population_snapshot.issue_id = issue.id AND direct_population_snapshot.member_id = member.id")
            :add_field("direct_population_snapshot.weight")
            :add_where("direct_supporter_snapshot.event = issue.latest_snapshot_event")
        }
      }
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
}



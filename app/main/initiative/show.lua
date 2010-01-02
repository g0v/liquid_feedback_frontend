local initiative = Initiative:new_selector():add_where{ "id = ?", param.get_id()}:single_object_mode():exec()

slot.select("actions", function()
  ui.link{
    content = function()
      ui.image{ static = "icons/16/script.png" }
      slot.put(_"Show all initiatives")
    end,
    module = "issue",
    view = "show",
    id = initiative.issue.id
  }
end)

execute.view{
  module = "issue",
  view = "_show_head",
  params = { issue = initiative.issue }
}

local initiator = Initiator:by_pk(initiative.id, app.session.member.id)

--slot.put_into("html_head", '<link rel="alternate" type="application/rss+xml" title="RSS" href="../show/' .. tostring(initiative.id) .. '.rss" />')

execute.view{
  module = "supporter",
  view = "_show_box",
  params = { initiative = initiative }
}

slot.put_into("sub_title", encode.html(_"Initiative: '#{name}'":gsub("#{name}", initiative.shortened_name) ))

slot.select("actions", function()
  if not initiative.issue.fully_frozen and not initiative.issue.closed then
    ui.link{
      attr = { class = "action" },
      content = function()
        ui.image{ static = "icons/16/script_add.png" }
        slot.put(_"Create alternative initiative")
      end,
      module = "initiative",
      view = "new",
      params = { issue_id = initiative.issue.id }
    }
  end
end)


util.help("initiative.show")


ui.container{
  attr = { class = "vertical" },
  content = function()
    ui.container{
      attr = { class = "ui_field_label" },
      content = _"Discussion URL"
    }
    ui.tag{
      tag = "span",
      content = function()
        if initiative.discussion_url and #initiative.discussion_url > 0 then
          ui.link{
            attr = {
              class = "actions",
              target = "_blank",
              title = initiative.discussion_url
            },
            content = function()
              slot.put(encode.html(initiative.discussion_url))
            end,
            external = initiative.discussion_url
          }
        end
        slot.put(" ")
        if initiator then
          ui.link{
            attr = { class = "actions" },
            content = _"(change URL)",
            module = "initiative",
            view = "edit",
            id = initiative.id
          }
        end
      end
    }
  end
}



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
        local supported = Supporter:by_pk(initiative.id, app.session.member.id) and true or false
        if not supported then
          ui.field.text{
            attr = { class = "warning" },
            value = _"You are currently not supporting this initiative. By adding suggestions to this initiative you will automatically become a potential supporter."
          }
        end
        ui.field.text{ label = _"Title (80 chars max)",        name = "name" }
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


local current_draft_name = _"Current draft"
if initiative.issue.half_frozen then
  current_draft_name = _"Voting proposal"
end

if initiative.issue.state == "finished" then
  current_draft_name = _"Voted proposal"
end

local tabs = {
  {
    name = "current_draft",
    label = current_draft_name,
    content = function()
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
      execute.view{ module = "draft", view = "_show", params = { draft = initiative.current_draft } }
    end
  }
}

if initiative.issue.ranks_available then
  tabs[#tabs+1] = {
    name = "voter",
    label = _"Voter",
    content = function()
      execute.view{
        module = "member",
        view = "_list",
        params = {
          initiative = initiative,
          members_selector =  initiative.issue:get_reference_selector("direct_voters")
            :left_join("vote", nil, { "vote.initiative_id = ? AND vote.member_id = member.id", initiative.id })
            :add_field("direct_voter.weight as voter_weight")
            :add_field("coalesce(vote.grade, 0) as grade")
        }
      }
    end
  }
end

tabs[#tabs+1] = {
  name = "suggestion",
  label = _"Suggestions",
  content = function()
    execute.view{
      module = "suggestion",
      view = "_list",
      params = {
        initiative = initiative,
        suggestions_selector = initiative:get_reference_selector("suggestions")
      }
    }
    slot.put("<br />")
    if not initiative.issue.fully_frozen and not initiative.issue.closed then
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
}

tabs[#tabs+1] = {
  name = "satisfied_supporter",
  label = _"Supporter",
  content = function()
    execute.view{
      module = "member",
      view = "_list",
      params = {
        initiative = initiative,
        members_selector =  initiative:get_reference_selector("supporting_members_snapshot")
          :join("issue", nil, "issue.id = direct_supporter_snapshot.issue_id")
          :join("direct_interest_snapshot", nil, "direct_interest_snapshot.event = issue.latest_snapshot_event AND direct_interest_snapshot.issue_id = issue.id AND direct_interest_snapshot.member_id = member.id")
          :add_field("direct_interest_snapshot.weight")
          :add_where("direct_supporter_snapshot.event = issue.latest_snapshot_event")
          :add_where("direct_supporter_snapshot.satisfied")
      }
    }
  end
}

tabs[#tabs+1] = {
  name = "supporter",
  label = _"Potential supporter",
  content = function()
    execute.view{
      module = "member",
      view = "_list",
      params = {
        initiative = initiative,
        members_selector =  initiative:get_reference_selector("supporting_members_snapshot")
          :join("issue", nil, "issue.id = direct_supporter_snapshot.issue_id")
          :join("direct_interest_snapshot", nil, "direct_interest_snapshot.event = issue.latest_snapshot_event AND direct_interest_snapshot.issue_id = issue.id AND direct_interest_snapshot.member_id = member.id")
          :add_field("direct_interest_snapshot.weight")
          :add_where("direct_supporter_snapshot.event = issue.latest_snapshot_event")
          :add_where("NOT direct_supporter_snapshot.satisfied")
      }
    }
  end
}

tabs[#tabs+1] = {
  name = "initiators",
  label = _"Initiators",
  content = function()
    execute.view{ module = "member", view = "_list", params = { members_selector = initiative:get_reference_selector("initiating_members") } }
  end
}

tabs[#tabs+1] = {
  name = "drafts",
  label = _"Old drafts",
  content = function()
    execute.view{ module = "draft", view = "_list", params = { drafts = initiative.drafts } }
  end
}

tabs[#tabs+1] = {
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
}


ui.tabs(tabs)


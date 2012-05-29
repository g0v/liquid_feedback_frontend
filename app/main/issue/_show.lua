local issue = param.get("issue", "table")
local initiative_limit = param.get("initiative_limit", atom.integer)
local for_listing = param.get("for_listing", atom.boolean)

local direct_voter
if app.session.member_id then
  direct_voter = issue.member_info.direct_voted
end

local voteable = app.session.member_id and issue.state == 'voting' and
       app.session.member:has_voting_right_for_unit_id(issue.area.unit_id)

local vote_link_text = direct_voter and _"Change vote" or "Vote now"


local class = "issue"
if issue.is_interested then
  class = class .. " interested"
elseif issue.is_interested_by_delegation_to_member_id then
  class = class .. " interested_by_delegation"
end

ui.container{ attr = { class = class }, content = function()

  execute.view{ module = "delegation", view = "_info", params = { issue = issue } }

  ui.container{ attr = { class = "title" }, content = function()
    
    ui.link{
      attr = { class = "issue_id" },
      text = _("#{policy_name} ##{issue_id}", {
        policy_name = issue.policy.name,
        issue_id = issue.id
      }),
      module = "issue",
      view = "show",
      id = issue.id
    }
    if for_listing then
      ui.tag{ attr = { class = "extra" }, content = function()
        ui.tag{ content = issue.area.unit.name }
        slot.put(" &middot; ")
        ui.tag{ content = issue.area.name }
      end }
    end
  end }
  
  ui.tag{
    attr = { class = "content issue_policy_info" },
    tag = "div",
    content = function()
    
      ui.tag{ attr = { class = "event_name" }, content = issue.state_name }

      if issue.state_time_left then
        slot.put(" &middot; ")
        if issue.state_time_left:sub(1,1) == "-" then
          if issue.state == "accepted" then
            ui.tag{ content = _("Discussion starts soon") }
          elseif issue.state == "discussion" then
            ui.tag{ content = _("Verification starts soon") }
          elseif issue.state == "frozen" then
            ui.tag{ content = _("Voting starts soon") }
          elseif issue.state == "voting" then
            ui.tag{ content = _("Counting starts soon") }
          end
        else
          ui.tag{ content = _("#{time_left} left", { time_left = issue.state_time_left:gsub("days", _"days"):gsub("day", _"day") }) }
        end
      end

    end
  }

  ui.container{
    attr = { class = "content actions" }, content = function()
  
    if voteable then
      ui.link{
        content = vote_link_text,
        module = "vote",
        view = "list",
        params = { issue_id = issue.id }
      }
      slot.put(" &middot; ")
    end

    if app.session.member_id then
      execute.view{
        module = "interest",
        view = "_show_box",
        params = { issue = issue, initiative = initiative }
      }
      slot.put(" &middot; ")
    end

    if not issue.closed then
      if issue.member_info.own_delegation_scope ~= "issue" then
        ui.link{ text = _"Delegate issue", module = "delegation", view = "show", params = { issue_id = issue.id } }
      else
        ui.link{ text = _"Change issue delegation", module = "delegation", view = "show", params = { issue_id = issue.id } }
      end
      slot.put(" &middot; ")
    end

    if config.issue_discussion_url_func then
      local url = config.issue_discussion_url_func(issue)
      ui.link{
        attr = { target = "_blank" },
        external = url,
        content = _"Discussion on issue"
      }
      slot.put(" &middot; ")
    end

    if config.etherpad and app.session.member then
      ui.link{
        attr = { target = "_blank" },
        external = issue.etherpad_url,
        content = _"Issue pad"
      }
      slot.put(" &middot; ")
    end


    if app.session.member_id and app.session.member:has_voting_right_for_unit_id(issue.area.unit_id) then
      if not issue.fully_frozen and not issue.closed then
        ui.link{
          attr   = { class = "action" },
          text   = _"Create alternative initiative",
          module = "initiative",
          view   = "new",
          params = { issue_id = issue.id }
        }
      end
    end

  end }

  if not for_listing then
    
    if voteable then
      ui.container{
        attr = { class = "voting_active_info" },
        content = function()
          slot.put(_"Voting for this issue is currently running!")
          slot.put(" ")
          if app.session.member_id then
            ui.link{
              content = vote_link_text,
              module = "vote",
              view = "list",
              params = { issue_id = issue.id }
            }
          end
        end
      }
    end

    if issue.state == "cancelled" then
      local policy = issue.policy
      ui.container{
        attr = { class = "not_admitted_info" },
        content = _("This issue has been cancelled. It failed the quorum of #{quorum}.", { quorum = format.percentage(policy.issue_quorum_num / policy.issue_quorum_den) })
      }
    end

  end

  ui.container{ attr = { class = "initiative_list" }, content = function()

    local initiatives_selector = issue:get_reference_selector("initiatives")
    local highlight_string = param.get("highlight_string")
    if highlight_string then
      initiatives_selector:add_field( {'"highlight"("initiative"."name", ?)', highlight_string }, "name_highlighted")
    end
    execute.view{
      module = "initiative",
      view = "_list",
      params = {
        issue = issue,
        initiatives_selector = initiatives_selector,
        highlight_string = highlight_string,
        per_page = initiative_limit,
        no_sort = true,
        limit = initiative_limit,
        for_member = for_member
      }
    }
  end }
end }


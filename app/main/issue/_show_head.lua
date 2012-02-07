local issue = param.get("issue", "table")
local initiative = param.get("initiative", "table")

local direct_voter

if app.session.member_id then
  direct_voter = DirectVoter:by_pk(issue.id, app.session.member.id)
end

if config.feature_rss_enabled then
  util.html_rss_head{ title = _"Initiatives in this issue (last created first)", module = "initiative", view = "list_rss", params = { issue_id = issue.id } }
  util.html_rss_head{ title = _"Initiatives in this issue (last updated first)", module = "initiative", view = "list_rss", params = { issue_id = issue.id, order = "last_updated" } }
end

slot.select("path", function()
end)

slot.select("title", function()
  ui.link{
    content = _("Issue ##{id}", { id = issue.id }),
    module = "issue",
    view = "show",
    id = issue.id
  }
    slot.put(" &middot; ")
  ui.link{
    content = issue.area.name,
    module = "area",
    view = "show",
    id = issue.area.id
  }
  if not config.single_unit_id then
    slot.put(" &middot; ")
    ui.link{
      content = issue.area.unit.name,
      module = "area",
      view = "list",
      params = { unit_id = issue.area.unit_id }
    }
  end
end)


slot.select("title2", function()
  ui.tag{
    tag = "div",
    content = function()
      ui.tag{
        content = function()
          ui.link{
            text = issue.policy.name,
            module = "policy",
            view = "show",
            id = issue.policy.id
          }
        end
      }
      slot.put(" &middot; ")
      ui.tag{ content = issue.state_name }

      slot.put(" &middot; ")
      local time_left = issue.state_time_left
      if time_left then
        ui.tag{ content = _("#{time_left} left", { time_left = time_left }) }
      end

      slot.put(" &middot; ")
      local next_state_names = issue.next_states_names
      if next_state_names then
        ui.tag{ content = _("Next state: #{state}", { state = next_state_names }) }
      end
    end
  }

  
end)


    --[[
slot.select("content_navigation", function()

  if app.session.member_id then
    local records
    local this = 0
    local issues_selector = Issue:new_selector()

    -- FIXME: !DRY
    local issue_filter_map = {
      new = "new.png",
      accepted = "comments.png",
      half_frozen = "lock.png",
      frozen ="email_open.png",
      finished = "tick.png",
      cancelled = "cross.png",
    }


    local mk_link = function(index, text, icon, module)
       content = function()
          if index > 0 then
            slot.put(text)
            ui.image{ static = "icons/16/"..icon }
          else
            ui.image{ static = "icons/16/"..icon }
            slot.put(text)
          end
      end
      if records[this+index] then
        ui.link{
          content = content,
          module = module,
          view = "show",
          id = records[this+index].id,
        }
      else
        ui.container{
          content = content,
        }
      end
    end

    issues_selector
       :add_where{"issue.area_id = ?", issue.area.id}

    local filters = execute.load_chunk{module="issue", chunk="_filters.lua", params = {filter = "frozen"}}

    local state = issue.state

    -- FIXME: fix filter names to reflect issue.state values
    if state == "voting" then
      state = "frozen"
    elseif state == "frozen" then
      state = "half_frozen"
    end

    filter = filters:get_filter("filter", state)
    if filter then
      filter.selector_modifier(issues_selector)

      -- add subfilter to voting pager, so only not voted entries will be shown
      -- as this seems the most usefull exception
      if filter.name == "frozen" then
        filter_voting_name = "not_voted"
        local vfilter = filters:get_filter("filter_voting", "not_voted")
        if vfilter then
          vfilter.selector_modifier(issues_selector)
        end
      end
    end

    records = issues_selector:exec()

    for i,cissue in ipairs(records) do
      if cissue.id == issue.id then
        this = i
        break
      end
    end

    mk_link(-1, _("Previous issue"), "resultset_previous.png", "issue")
    if issue.area then
      ui.link{
        content = function()
          if issue_filter_map[state] then
            ui.image{ static = "icons/16/"..issue_filter_map[state] }
          end
          slot.put(issue.area.name)
        end,
        module = "area",
        view = "show",
        id = issue.area.id,
        params = {
          filter = filter and filter.name or nil,
          filter_voting = filter_voting_name,
          tab = "issues"
        }
      }
    end
    mk_link(1, _("Next issue"), "resultset_next.png", "issue")

    -- show pager for initiatives if available
    if initiative then
      ui.container{ content = function() end, attr = {class = "content_navigation_seperator"}}

      records = issue:get_reference_selector("initiatives"):exec()
      for i,cissue in ipairs(records) do
        if cissue.id == initiative.id then
          this = i
          break
        end
      end
      mk_link(-1, _("Previous initiative"), "resultset_previous.png", "initiative")
      mk_link(1, _("Next initiative"), "resultset_next.png", "initiative")
    end
  end
end

)
    --]]

slot.select("actions", function()

  if app.session.member_id then

    if issue.state == 'voting' then
      local text
      if not direct_voter then
        text = _"Vote now"
      else
        text = _"Change vote"
      end
      ui.link{
        content = function()
          ui.image{ static = "icons/16/email_open.png" }
          slot.put(text)
        end,
        module = "vote",
        view = "list",
        params = { issue_id = issue.id }
      }
    end

    execute.view{
      module = "interest",
      view = "_show_box",
      params = { issue = issue }
    }

    if not issue.closed then
      execute.view{
        module = "delegation",
        view = "_show_box",
        params = { issue_id = issue.id,
                   initiative_id = initiative and initiative.id or nil}
      }
    end

  end

  if config.issue_discussion_url_func then
    local url = config.issue_discussion_url_func(issue)
    ui.link{
      attr = { target = "_blank" },
      external = url,
      content = function()
        ui.image{ static = "icons/16/comments.png" }
        slot.put(_"Discussion on issue")
      end,
    }
  end
end)


local issue = param.get("issue", "table")



--  ui.twitter("http://example.com/t" .. tostring(issue.id))

if config.public_access_issue_head and not app.session.member_id then
  config.public_access_issue_head(issue)
end

if app.session.member_id and issue.state == 'voting' and not direct_voter then
  ui.container{
    attr = { class = "voting_active_info" },
    content = function()
      slot.put(_"Voting for this issue is currently running!")
      slot.put(" ")
      if app.session.member_id then
        ui.link{
          content = function()
            slot.put(_"Vote now")
          end,
          module = "vote",
          view = "list",
          params = { issue_id = issue.id }
        }
      end
    end
  }
  slot.put("<br />")
end


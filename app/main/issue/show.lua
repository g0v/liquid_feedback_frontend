local issue = Issue:by_id(param.get_id())

if not app.html_title.title then
	app.html_title.title = _("Issue ##{id}", { id = issue.id })
end

execute.view{
  module = "issue",
  view = "_show_head",
  params = { issue = issue }
}

--[[
if not issue.fully_frozen and not issue.closed then
  slot.select("actions", function()
    ui.link{
      content = function()
        ui.image{ static = "icons/16/script_add.png" }
        slot.put(_"Create alternative initiative")
      end,
      module = "initiative",
      view = "new",
      params = { issue_id = issue.id }
    }
  end)
end
--]]

util.help("issue.show")

if issue.state == "cancelled" then
  local policy = issue.policy
  ui.container{
    attr = { class = "not_admitted_info" },
    content = _("This issue has been cancelled. It failed the quorum of #{quorum}.", { quorum = format.percentage(policy.issue_quorum_num / policy.issue_quorum_den) })
  }
end

ui.container{
  attr = { class = "issue_initiative_list" },
  content = function()
    execute.view{
      module = "initiative",
      view = "_list",
      params = {
        initiatives_selector = issue:get_reference_selector("initiatives"),
        issue = issue,
        expandable = true,
        for_initiative_id = param.get("for_initiative_id", atom.number),
        show_for_issue = true
      }
    }
  end
}

slot.put("<br />")

execute.view{
  module = "issue",
  view = "show_tab",
  params = { issue = issue }
}

if issue.snapshot then
  slot.put("<br />")
  ui.field.timestamp{ label = _"Last snapshot:", value = issue.snapshot }
end


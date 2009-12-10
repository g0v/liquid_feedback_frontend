local issue = param.get("issue", "table")

slot.put_into("html_head", '<link rel="alternate" type="application/rss+xml" title="RSS" href="../show/' .. tostring(issue.id) .. '.rss" />')

slot.select("path", function()
  ui.link{
    content = _"Area '#{name}'":gsub("#{name}", issue.area.name),
    module = "area",
    view = "show",
    id = issue.area.id
  }
end)

slot.put_into("title", encode.html(_"Issue ##{id} (#{policy_name})":gsub("#{id}", issue.id):gsub("#{policy_name}", issue.policy.name)))

slot.select("actions", function()
  execute.view{
    module = "interest",
    view = "_show_box",
    params = { issue = issue }
  }
  
  execute.view{
    module = "delegation",
    view = "_show_box",
    params = { issue_id = issue.id }
  }
  
  -- TODO performance
  local interest = Interest:by_pk(issue.id, app.session.member.id)
  if not issue.closed and not issue.fully_frozen then
    if not interest then
      ui.link{
        content = function()
          ui.image{ static = "icons/16/user_add.png" }
          slot.put(_"Add my interest")
        end,
        module = "interest",
        action = "update",
        params = { issue_id = issue.id },
        routing = { default = { mode = "redirect", module = "issue", view = "show", id = issue.id } }
      }
    end
  end


end)


execute.view{
  module = "issue",
  view = "_show_box",
  params = { issue = issue }
}

--  ui.twitter("http://example.com/t" .. tostring(issue.id))

local initiative = param.get("initiative", "table")

if not initiative then
  initiative = Initiative:new_selector():add_where{ "id = ?", param.get_id()}:single_object_mode():exec()
end

slot.select("actions", function()
  ui.link{
    content = function()
      local count = Initiative:new_selector():add_where{ "issue_id = ?", initiative.issue.id}:count()-1
      ui.image{ static = "icons/16/script.png" }
      if count and count > 0 then
        slot.put(_("Show alternative initiatives (#{count})", {count=count}))
      else
        slot.put(_"Show alternative initiatives")
      end
    end,
    module = "issue",
    view = "show",
    id = initiative.issue.id
  }
end)

execute.view{
  module = "issue",
  view = "_show_head",
  params = { issue = initiative.issue,
             initiative = initiative }
}

--slot.put_into("html_head", '<link rel="alternate" type="application/rss+xml" title="RSS" href="../show/' .. tostring(initiative.id) .. '.rss" />')

if app.session.member_id then
  slot.select("actions", function()
    if not initiative.issue.fully_frozen and not initiative.issue.closed then
      ui.link{
        image  = { static = "icons/16/script_add.png" },
        attr   = { class = "action" },
        text   = _"Create alternative initiative",
        module = "initiative",
        view   = "new",
        params = { issue_id = initiative.issue.id }
      }
    end
  end)
end

slot.put_into("sub_title", encode.html(_("Initiative: '#{name}'", { name = initiative.name }) ))

execute.view{
  module = "initiative",
  view = "show_partial",
  params = {
    initiative = initiative,
    expanded = true
  }
}

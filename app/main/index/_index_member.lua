-- quick links
ui.actions(function()
  ui.link{
    text = "Neuste Abstimmungsergebnisse",
    module = "index",
    view = "index",
    params = {
      tab = "closed",
      filter = "finished",
      filter_interest = "unit"
    }
  }
  slot.put(" &middot; ")
  ui.link{
    text = "Abgestimmt durch Delegationen",
    module = "index",
    view = "index",
    params = {
      tab = "closed",
      filter_interest = "voted",
      filter_delegation = "delegated"
    }
  }
  slot.put(" &middot; ")
  ui.link{
    text = "Noch nicht abgestimmt",
    module = "index",
    view = "index",
    params = {
      tab = "open",
      filter = "frozen",
      filter_interest = "unit"
    }
  }
end)

local tabs = {
  module = "index",
  view = "index"
}

tabs[#tabs+1] = {
  name = "areas",
  label = _"Home",
  module = "index",
  view = "_member_home",
  params = { member = app.session.member }
}

tabs[#tabs+1] = {
  name = "open",
  label = _"Open issues",
  module = "issue",
  view = "_list",
  params = {
    for_state = "open",
    issues_selector = Issue:new_selector()
      :add_where("issue.closed ISNULL")
      :add_order_by("coalesce(issue.fully_frozen + issue.voting_time, issue.half_frozen + issue.verification_time, issue.accepted + issue.discussion_time, issue.created + issue.admission_time) - now()")
  }
}

tabs[#tabs+1] = {
  name = "closed",
  label = _"Closed issues",
  module = "issue",
  view = "_list",
  params = {
    for_state = "closed",
    issues_selector = Issue:new_selector()
      :add_where("issue.closed NOTNULL")
      :add_order_by("issue.closed DESC")

  }
}

tabs[#tabs+1] = {
  name = "timeline",
  label = _"Latest events",
  module = "event",
  view = "_list"
}

tabs[#tabs+1] = {
  name = "members",
  label = _"Members",
  module = 'member',
  view   = '_list',
  params = {
    members_selector = Member:new_selector()
      :add_where("active")
      :left_join("contact", nil, { "contact.other_member_id = member.id AND contact.member_id = ?", app.session.member_id })
      :add_field("contact.member_id NOTNULL", "saved")
  }
}

if not param.get("tab") then
  execute.view{
    module = "index", view = "_notifications"
  }
end

ui.tabs(tabs)

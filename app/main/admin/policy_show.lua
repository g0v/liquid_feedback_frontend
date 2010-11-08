local policy = Policy:by_id(param.get_id()) or Policy:new()


slot.put_into("title", _"Create / edit policy")


slot.select("actions", function()
  ui.link{
    attr = { class = { "admin_only" } },
    text = _"Cancel",
    module = "admin",
    view = "policy_list"
  }
end)


ui.form{
  attr = { class = "vertical" },
  record = policy,
  module = "admin",
  action = "policy_update",
  routing = {
    default = {
      mode = "redirect",
      module = "admin",
      view = "policy_list"
    }
  },
  id = policy.id,
  content = function()

    ui.field.text{ label = _"Index",        name = "index" }

    ui.field.text{ label = _"Name",        name = "name" }
    ui.field.text{ label = _"Description", name = "description", multiline = true }
    ui.field.text{ label = _"Hint",        readonly = true, 
                    value = _"Interval format:" .. " 3 mons 2 weeks 1 day 10:30:15" }

    ui.field.text{ label = _"Admission time",     name = "admission_time" }
    ui.field.text{ label = _"Discussion time",    name = "discussion_time" }
    ui.field.text{ label = _"Verification time",  name = "verification_time" }
    ui.field.text{ label = _"Voting time",        name = "voting_time" }

    ui.field.text{ label = _"Issue quorum numerator",   name = "issue_quorum_num" }
    ui.field.text{ label = _"Issue quorum denumerator", name = "issue_quorum_den" }

    ui.field.text{ label = _"Initiative quorum numerator",   name = "initiative_quorum_num" }
    ui.field.text{ label = _"Initiative quorum denumerator", name = "initiative_quorum_den" }

    ui.field.text{ label = _"Majority numerator",   name = "majority_num" }
    ui.field.text{ label = _"Majority denumerator", name = "majority_den" }

    ui.field.boolean{ label = _"Strict majority", name = "majority_strict" }

    ui.field.boolean{ label = _"Active?", name = "active" }

    ui.submit{ text = _"Save" }
  end
}

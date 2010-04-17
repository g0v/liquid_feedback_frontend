local initiatives_selector = Initiative:new_selector()
  :join("issue", "_issue_state", "_issue_state.id = initiative.issue_id AND _issue_state.closed ISNULL AND _issue_state.fully_frozen ISNULL")
  :join("current_draft", "_current_draft", "_current_draft.initiative_id = initiative.id")
  :join("supporter", "supporter", { "supporter.member_id = ? AND supporter.initiative_id = initiative.id AND supporter.draft_id < _current_draft.id", app.session.member_id })

if initiatives_selector:count() > 0 then
  ui.container{
    attr = { style = "font-weight: bold;" },
    content = _"Open initiatives you are supporting which has been updated their draft:"
  }

  execute.view{
    module = "initiative",
    view = "_list",
    params = { initiatives_selector = initiatives_selector }
  }
end
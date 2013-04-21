ui.title(_"Open initiatives you are supporting which have been updated their draft:")

slot.put("<br />")

local initiatives_selector = Initiative:selector_for_updated_drafts(app.session.member_id)
execute.view{
  module = "initiative",
  view = "_list",
  params = { initiatives_selector = initiatives_selector }
}

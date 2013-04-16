local old_draft_id = param.get("old_draft_id", atom.integer)
local new_draft_id = param.get("new_draft_id", atom.integer)

if not old_draft_id or not new_draft_id then
  slot.put_into("error", _"Please choose two versions of the draft to compare!")
  return
end

if old_draft_id == new_draft_id then
  slot.put_into("error", _"Please choose two different versions of the draft to compare!")
  return
end

if old_draft_id > new_draft_id then
  local tmp = old_draft_id
  old_draft_id = new_draft_id
  new_draft_id = tmp
end

local old_draft = Draft:by_id(old_draft_id)
local new_draft = Draft:by_id(new_draft_id)

execute.view{
  module = "draft",
  view = "_head",
  params = {
    draft = new_draft,
    title = _("Difference between the drafts from #{old} and #{new}", {
      old = format.timestamp(old_draft.created),
      new = format.timestamp(new_draft.created)
    })
  }
}

-- message about new draft
local initiative = new_draft.initiative
if app.session.member_id and not initiative.revoked and not initiative.issue.closed then
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
          slot.put(_"The draft of this initiative has been updated!")
          slot.put(" ")
          ui.link{
            text   = _"Refresh support to current draft",
            module = "initiative",
            action = "add_support",
            id     = initiative.id,
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
end

local diff1 = util.diff(old_draft.name,    new_draft.name)
local diff2 = util.diff(old_draft.content, new_draft.content)
if not diff1 and not diff2 then
  slot.put_into("warning", _"The versions do not differ.")
end

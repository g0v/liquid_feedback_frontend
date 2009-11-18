db:query("BEGIN")

local suggestion = Suggestion:new()

suggestion.author_id = app.session.member.id
param.update(suggestion, "name", "description", "initiative_id")
suggestion:save()

local opinion = Opinion:new()

opinion.suggestion_id = suggestion.id
opinion.member_id     = app.session.member.id
opinion.degree        = param.get("degree", atom.integer)
opinion.fulfilled     = false

opinion:save()

db:query("COMMIT")

slot.put_into("notice", _"Your suggestion has been added")
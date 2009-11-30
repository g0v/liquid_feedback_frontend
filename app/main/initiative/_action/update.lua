local initiative = Initiative:by_id(param.get_id())
param.update(initiative, "discussion_url")
initiative:save()

slot.put_into("notice", _"Initiative successfully updated")


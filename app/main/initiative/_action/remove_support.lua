local initiative = Initiative:new_selector():add_where{ "id = ?", param.get_id()}:single_object_mode():exec()

local member = app.session.member

local supporter = Supporter:by_pk(initiative.id, member.id)

if supporter then  
  supporter:destroy()
  slot.put_into("notice", _"Your support has been removed from this initiative")
else
  slot.put_into("notice", _"You are already not supporting this initiative")
end
Issue = mondelefant.new_class()
Issue.table = 'issue'

Issue:add_reference{
  mode          = 'm1',
  to            = "Area",
  this_key      = 'area_id',
  that_key      = 'id',
  ref           = 'area',
}

Issue:add_reference{
  mode          = 'm1',
  to            = "Policy",
  this_key      = 'policy_id',
  that_key      = 'id',
  ref           = 'policy',
}

Issue:add_reference{
  mode          = '1m',
  to            = "Initiative",
  this_key      = 'id',
  that_key      = 'issue_id',
  ref           = 'initiatives',
  back_ref      = 'issue'
}

Issue:add_reference{
  mode          = '1m',
  to            = "Interest",
  this_key      = 'id',
  that_key      = 'issue_id',
  ref           = 'interests',
  back_ref      = 'issue',
  default_order = '"id"'
}

Issue:add_reference{
  mode          = '1m',
  to            = "Supporter",
  this_key      = 'id',
  that_key      = 'issue_id',
  ref           = 'supporters',
  back_ref      = 'issue',
  default_order = '"id"'
}

Issue:add_reference{
  mode          = '1m',
  to            = "DirectVoter",
  this_key      = 'id',
  that_key      = 'issue_id',
  ref           = 'direct_voters',
  back_ref      = 'issue',
  default_order = '"member_id"'
}

Issue:add_reference{
  mode          = '1m',
  to            = "Vote",
  this_key      = 'id',
  that_key      = 'issue_id',
  ref           = 'votes',
  back_ref      = 'issue',
  default_order = '"member_id", "initiative_id"'
}

Issue:add_reference{
  mode          = '1m',
  to            = "Delegation",
  this_key      = 'id',
  that_key      = 'issue_id',
  ref           = 'delegations',
  back_ref      = 'issue'
}

Issue:add_reference{
  mode                  = 'mm',
  to                    = "Member",
  this_key              = 'id',
  that_key              = 'id',
  connected_by_table    = 'interest',
  connected_by_this_key = 'issue_id',
  connected_by_that_key = 'member_id',
  ref                   = 'members'
}

function Issue:get_state_name_for_state(value)
  local state_name_table = {
    new          = _"New",
    accepted     = _"Accepted",
    frozen       = _"Frozen",
    voting       = _"Voting",
    finished     = _"Finished",
    cancelled    = _"Cancelled"
  }
  return state_name_table[value] or value
end

function Issue:get_search_selector(search_string)
  return self:new_selector()
    :join('"initiative"', nil, '"initiative"."issue_id" = "issue"."id"')
    :add_where{ '"initiative"."text_search_data" @@ "text_search_query"(?)', search_string }
    :set_distinct()
end

function Issue.object_get:state()
  if self.accepted then
    if self.fully_frozen then
      return "voting"
    elseif self.half_frozen then
      return "frozen"
    elseif self.closed then
      if self.ranks_available then
        return "finished"
      else
        return "cancelled"
      end
    else
      return "accepted"
    end
  else
    if self.closed then
      return "cancelled"
    else
      return "new"
    end
  end
end

function Issue.object_get:state_name()
  return Issue:get_state_name_for_state(self.state)
end

function Issue.object_get:state_time_left()
  local state = self.state
  local last_event_time
  local duration
  if state == "new" then
    last_event_time = self.created
    duration = self.policy.admission_time
  elseif state == "accepted" then
    last_event_time = self.accepted
    duration =  self.policy.discussion_time
  elseif state == "frozen" then
    last_event_time = self.half_frozen
    duration = self.policy.verification_time
  elseif state == "voting" then
    last_event_time = self.fully_frozen
    duration = self.policy.voting_time
  end
  return db:query{ "SELECT ?::timestamp + ?::interval - now() as time_left", last_event_time, duration }[1].time_left
end

function Issue.object_get:next_states()
  local state = self.state
  local next_states
  if state == "new" then
    next_states = { "accepted", "cancelled" }
  elseif state == "accepted" then
    next_states = { "frozen" }
  elseif state == "frozen" then
    next_states = { "voting" }
  elseif state == "voting" then
    next_states = { "finished" }
  end
  return next_states
end

function Issue.object_get:next_states_names()
  local next_states = self.next_states
  if not next_states then
    return
  end
  local state_names = {}
  for i, state in ipairs(self.next_states) do
    state_names[#state_names+1] = Issue:get_state_name_for_state(state)
  end
  return table.concat(state_names, ", ")
end
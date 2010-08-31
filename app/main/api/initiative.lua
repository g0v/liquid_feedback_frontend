local id             = param.get("id")
local min_id         = param.get("min_id")
local max_id         = param.get("max_id")
local area_id        = param.get("area_id", atom.integer)
local issue_id       = param.get("issue_id", atom.integer)
local policy_id      = param.get("policy_id", atom.integer)
local state          = param.get("state")
local agreed         = param.get("agreed")
local rank           = param.get("rank")
--local search         = param.get("search")
--local search_context = param.get("search_context") or "full"
local limit          = param.get("limit", atom.integer)
local order          = param.get("order")
local render_draft   = param.get("render_draft")

if render_draft and render_draft ~= "html" then
  error("unsupported render target, only 'html' is supported right now")
end

local initiatives_selector = Initiative:new_selector()
  :join("issue", nil, "issue.id = initiative.issue_id")
  :join("area", nil, "area.id = issue.area_id")
  :join("policy", nil, "policy.id = issue.policy_id")

if id then
  initiatives_selector:add_where{"initiative.id = ?", id}
end

if min_id then
  initiatives_selector:add_where{"initiative.id >= ?", min_id}
end

if max_id then
  initiatives_selector:add_where{"initiative.id <= ?", max_id}
end

if area_id then
  initiatives_selector:add_where{"area.id = ?", area_id}
end

if issue_id then
  initiatives_selector:add_where{"issue.id = ?", issue_id}
end

if policy_id then
  initiatives_selector:add_where{"policy.id = ?", policy_id}
end

if state then
  Issue:modify_selector_for_state(initiatives_selector, state)
end

if agreed then
  initiatives_selector:add_where("initiative.agreed")
end

if rank then
  initiatives_selector:add_where{ "initiative.rank = ?", rank }
end

--[[
if search then
  if search_context == "full" then
  elseif search_context == "title" then
  end
end
--]]

if order == "supporter_count" then
  initiatives_selector:add_order_by("initiative.supporter_count")
end

if order == "id_desc" then
  initiatives_selector:add_order_by("initiative.id DESC")
else
  initiatives_selector:add_order_by("initiative.id")
end

if limit then
  initiatives_selector:limit(limit)
end

local api_engine = param.get("api_engine") or "xml"

local function format_timestamp(timestamp)
  if timestamp then
    return format.timestamp(timestamp)
  else
    return ""
  end
end

local fields = {

  { name = "area_id",                   field = "area.id" },
  { name = "area_name",                 field = "area.name" },
  { name = "issue_id",                  field = "issue.id" },
  {
    name = "issue_state",
    func = function(record)
      return record.issue.state
    end
  },
  {
    name = "issue_created",
    field = "issue.created",
    func = function(record)
      return format_timestamp(record.issue_created)
    end
  },
  {
    name = "issue_accepted",
    field = "issue.accepted",
    func = function(record)
      return format_timestamp(record.issue_accepted)
    end
  },
  {
    name = "issue_half_frozen",
    field = "issue.half_frozen",
    func = function(record)
      return format_timestamp(record.issue_half_frozen)
    end
  },
  {
    name = "issue_fully_frozen",
    field = "issue.fully_frozen",
    func = function(record)
      return format_timestamp(record.issue_fully_frozen)
    end
  },
  {
    name = "issue_closed",
    field = "issue.closed",
    func = function(record)
      return format_timestamp(record.issue_closed)
    end
  },
  { name = "issue_admission_time",      field = "issue.admission_time" },
  { name = "issue_discussion_time",     field = "issue.discussion_time" },
  { name = "issue_verification_time",   field = "issue.verification_time" },
  { name = "issue_voting_time",         field = "issue.voting_time" },
  { name = "issue_ranks_available",     field = "issue.ranks_available" },

  { name = "policy_issue_quorum_num",   field = "policy.issue_quorum_num" },
  { name = "policy_issue_quorum_den",   field = "policy.issue_quorum_den" },
  { name = "policy_initiative_quorum_num",
                                        field = "policy.initiative_quorum_num" },
  { name = "policy_initiative_quorum_den",
                                        field = "policy.initiative_quorum_den" },
  { name = "policy_majority_num",       field = "policy.majority_num" },
  { name = "policy_majority_den",       field = "policy.majority_den" },
  { name = "policy_majority_strict",    field = "policy.majority_strict" },
  { name = "id",                        field = "initiative.id" },
  { name = "name",                      field = "initiative.name" },
  { name = "discussion_url",            field = "initiative.discussion_url" },
  {
    name = "created",
    field = "initiative.created",
    func = function(record)
      return format_timestamp(record.created)
    end
  },
  {
    name = "revoked",
    field = "initiative.revoked",
    func = function(record)
      return format_timestamp(record.revoked)
    end
  },
  { name = "suggested_initiative_id",   field = "initiative.suggested_initiative_id" },
  { name = "admitted",                  field = "initiative.admitted" },
  { name = "issue_population",          field = "issue.population" },
  { name = "supporter_count",           field = "initiative.supporter_count" },
  { name = "informed_supporter_count",  field = "initiative.informed_supporter_count" },
  { name = "satisfied_supporter_count", field = "initiative.satisfied_supporter_count" },
  { name = "satisfied_informed_supporter_count",
                                        field = "initiative.satisfied_informed_supporter_count" },
  { name = "issue_vote_now",            field = "issue.vote_now" },
  { name = "issue_vote_later",          field = "issue.vote_later" },
  { name = "issue_voter_count",         field = "issue.voter_count" },
  { name = "positive_votes",            field = "initiative.positive_votes" },
  { name = "negative_votes",            field = "initiative.negative_votes" },
  { name = "agreed",                    field = "initiative.agreed" },
  { name = "rank",                      field = "initiative.rank" },
  {
    name = "current_draft_created",
    func = function(record)
      return format_timestamp(record.current_draft.created)
    end
  },
  {
    name = "current_draft_formatting_engine",
    func = function(record)
      return record.current_draft.formatting_engine
    end
  },
  {
    name = "current_draft_content",
    func = function(record)
      if render_draft then
        return record.current_draft:get_content(render_draft)
      else
        return record.current_draft.content
      end
    end
  }
}

util.autoapi{
  relation_name = "initiative",
  selector      = initiatives_selector,
  fields        = fields,
  api_engine    = api_engine
}
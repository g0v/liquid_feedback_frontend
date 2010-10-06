local issue = Issue:by_id(param.get("issue_id"), atom.integer)

local member_id = param.get("member_id", atom.integer)
local member

local readonly = false
if member_id then
  if not issue.closed then
    error("access denied")
  end
  member = Member:by_id(member_id)
  readonly = true
end

if issue.closed then
  slot.put_into("error", _"This issue is already closed.")

  slot.select("actions", function()
    ui.link{
      content = _("Issue ##{id}", { id = issue.id }),
      module = "issue",
      view = "show",
      id = issue.id
    }
    end
  )
  return
end

if member then
  slot.put_into("title", _("Ballot of '#{member_name}' for issue ##{issue_id}", {
    member_name = member.name,
    issue_id = issue.id
  }))
else
  member = app.session.member
  slot.put_into("title", _"Voting")

  slot.select("actions", function()
    ui.link{
      content = function()
          ui.image{ static = "icons/16/cancel.png" }
          slot.put(_"Cancel")
      end,
      module = "issue",
      view = "show",
      id = issue.id
    }
    ui.link{
      text = _"Discard voting",
      content = function()
          ui.image{ static = "icons/16/email_delete.png" }
          slot.put(_"Discard voting")
      end,
      module = "vote",
      action = "update",
      params = {
        issue_id = issue.id,
        discard = true
      },
      routing = {
        default = {
          mode = "redirect",
          module = "issue",
          view = "show",
          id = issue.id
        }
      }
    }
  end)
end


local warning_text = _"Some JavaScript based functions (voting in particular) will not work.\nFor this beta, please use a current version of Firefox, Safari, Opera(?), Konqueror or another (more) standard compliant browser.\nAlternative access without JavaScript will be available soon."

ui.script{ static = "js/browser_warning.js" }
ui.script{ script = "checkBrowser(" .. encode.json(_"Your web browser is not fully supported yet." .. " " .. warning_text:gsub("\n", "\n\n")) .. ");" }


local tempvoting_string = param.get("scoring")

local tempvotings = {}
if tempvoting_string then
  for match in tempvoting_string:gmatch("([^;]+)") do
    for initiative_id, grade in match:gmatch("([^:;]+):([^:;]+)") do
      tempvotings[tonumber(initiative_id)] = tonumber(grade)
    end
  end
end

local initiatives = issue:get_reference_selector("initiatives"):add_where("initiative.admitted"):add_order_by("initiative.satisfied_supporter_count DESC"):exec()

local min_grade = -1;
local max_grade = 1;

for i, initiative in ipairs(initiatives) do
  -- TODO performance
  initiative.vote = Vote:by_pk(initiative.id, member.id)
  if tempvotings[initiative.id] then
    initiative.vote = {}
    initiative.vote.grade = tempvotings[initiative.id]
  end
  if initiative.vote then
    if initiative.vote.grade > max_grade then
      max_grade = initiative.vote.grade
    end
    if initiative.vote.grade < min_grade then
      min_grade = initiative.vote.grade
    end
  end
end

local sections = {}
for i = min_grade, max_grade do
  sections[i] = {}
  for j, initiative in ipairs(initiatives) do
    if (initiative.vote and initiative.vote.grade == i) or (not initiative.vote and i == 0) then
      sections[i][#(sections[i])+1] = initiative
    end
  end
end

local approval_count, disapproval_count = 0, 0
for i = min_grade, -1 do
  if #sections[i] > 0 then
    disapproval_count = disapproval_count + 1
  end
end
local approval_count = 0
for i = 1, max_grade do
  if #sections[i] > 0 then
    approval_count = approval_count + 1
  end
end



if not readonly then
  util.help("vote.list", _"Voting")
  slot.put('<script src="' .. request.get_relative_baseurl() .. 'static/js/dragdrop.js"></script>')
  slot.put('<script src="' .. request.get_relative_baseurl() .. 'static/js/voting.js"></script>')
end

ui.script{
  script = function()
    slot.put(
      "voting_text_approval_single               = ", encode.json(_"Approval [single entry]"), ";\n",
      "voting_text_approval_multi                = ", encode.json(_"Approval [many entries]"), ";\n",
      "voting_text_first_preference_single       = ", encode.json(_"Approval (first preference) [single entry]"), ";\n",
      "voting_text_first_preference_multi        = ", encode.json(_"Approval (first preference) [many entries]"), ";\n",
      "voting_text_second_preference_single      = ", encode.json(_"Approval (second preference) [single entry]"), ";\n",
      "voting_text_second_preference_multi       = ", encode.json(_"Approval (second preference) [many entries]"), ";\n",
      "voting_text_third_preference_single       = ", encode.json(_"Approval (third preference) [single entry]"), ";\n",
      "voting_text_third_preference_multi        = ", encode.json(_"Approval (third preference) [many entries]"), ";\n",
      "voting_text_numeric_preference_single     = ", encode.json(_"Approval (#th preference) [single entry]"), ";\n",
      "voting_text_numeric_preference_multi      = ", encode.json(_"Approval (#th preference) [many entries]"), ";\n",
      "voting_text_abstention_single             = ", encode.json(_"Abstention [single entry]"), ";\n",
      "voting_text_abstention_multi              = ", encode.json(_"Abstention [many entries]"), ";\n",
      "voting_text_disapproval_above_one_single  = ", encode.json(_"Disapproval (prefer to lower block) [single entry]"), ";\n",
      "voting_text_disapproval_above_one_multi   = ", encode.json(_"Disapproval (prefer to lower block) [many entries]"), ";\n",
      "voting_text_disapproval_above_many_single = ", encode.json(_"Disapproval (prefer to lower blocks) [single entry]"), ";\n",
      "voting_text_disapproval_above_many_multi  = ", encode.json(_"Disapproval (prefer to lower blocks) [many entries]"), ";\n",
      "voting_text_disapproval_above_last_single = ", encode.json(_"Disapproval (prefer to last block) [single entry]"), ";\n",
      "voting_text_disapproval_above_last_multi  = ", encode.json(_"Disapproval (prefer to last block) [many entries]"), ";\n",
      "voting_text_disapproval_single            = ", encode.json(_"Disapproval [single entry]"), ";\n",
      "voting_text_disapproval_multi             = ", encode.json(_"Disapproval [many entries]"), ";\n"
    )
  end
}

ui.form{
  attr = {
    id = "voting_form",
    class = readonly and "voting_form_readonly" or "voting_form_active"
  },
  module = "vote",
  action = "update",
  params = { issue_id = issue.id },
  routing = {
    default = {
      mode = "redirect",
      module = "issue",
      view = "show",
      id = issue.id
    }
  },
  content = function()
    if not readonly then
      local scoring = param.get("scoring")
      if not scoring then
        for i, initiative in ipairs(initiatives) do
          local vote = initiative.vote
          if vote then
            tempvotings[initiative.id] = vote.grade
          end
        end
        local tempvotings_list = {}
        for key, val in pairs(tempvotings) do
          tempvotings_list[#tempvotings_list+1] = tostring(key) .. ":" .. tostring(val)
        end
        if #tempvotings_list > 0 then
          scoring = table.concat(tempvotings_list, ";")
        else
          scoring = ""
        end
      end
      slot.put('<input type="hidden" name="scoring" value="' .. scoring .. '"/>')
      -- TODO abstrahieren
      ui.tag{
        tag = "input",
        attr = {
          type = "submit",
          class = "voting_done",
          value = _"Finish voting"
        }
      }
    end
    ui.container{
      attr = { id = "voting" },
      content = function()
        local approval_index, disapproval_index = 0, 0
        for grade = max_grade, min_grade, -1 do 
          local entries = sections[grade]
          local class
          if grade > 0 then
            class = "approval"
          elseif grade < 0 then
            class = "disapproval"
          else
            class = "abstention"
          end
          if
            #entries > 0 or
            (grade == 1 and not approval_used) or
            (grade == -1 and not disapproval_used) or
            grade == 0
          then
            ui.container{
              attr = { class = class },
              content = function()
                local heading
                if class == "approval" then
                  approval_used = true
                  approval_index = approval_index + 1
                  if approval_count > 1 then
                    if approval_index == 1 then
                      if #entries == 1 then
                        heading = _"Approval (first preference) [single entry]"
                      else
                        heading = _"Approval (first preference) [many entries]"
                      end
                    elseif approval_index == 2 then
                      if #entries == 1 then
                        heading = _"Approval (second preference) [single entry]"
                      else
                        heading = _"Approval (second preference) [many entries]"
                      end
                    elseif approval_index == 3 then
                      if #entries == 1 then
                        heading = _"Approval (third preference) [single entry]"
                      else
                        heading = _"Approval (third preference) [many entries]"
                      end
                    else
                      if #entries == 1 then
                        heading = _"Approval (#th preference) [single entry]"
                      else
                        heading = _"Approval (#th preference) [many entries]"
                      end
                    end
                  else
                    if #entries == 1 then
                      heading = _"Approval [single entry]"
                    else
                      heading = _"Approval [many entries]"
                    end
                  end
                elseif class == "abstention" then
                    if #entries == 1 then
                      heading = _"Abstention [single entry]"
                    else
                      heading = _"Abstention [many entries]"
                    end
                elseif class == "disapproval" then
                  disapproval_used = true
                  disapproval_index = disapproval_index + 1
                  if disapproval_count > disapproval_index + 1 then
                    if #entries == 1 then
                      heading = _"Disapproval (prefer to lower blocks) [single entry]"
                    else
                      heading = _"Disapproval (prefer to lower blocks) [many entries]"
                    end
                  elseif disapproval_count == 2 and disapproval_index == 1 then
                    if #entries == 1 then
                      heading = _"Disapproval (prefer to lower block) [single entry]"
                    else
                      heading = _"Disapproval (prefer to lower block) [many entries]"
                    end
                  elseif disapproval_index == disapproval_count - 1 then
                    if #entries == 1 then
                      heading = _"Disapproval (prefer to last block) [single entry]"
                    else
                      heading = _"Disapproval (prefer to last block) [many entries]"
                    end
                  else
                    if #entries == 1 then
                      heading = _"Disapproval [single entry]"
                    else
                      heading = _"Disapproval [many entries]"
                    end
                  end
                end
                ui.tag {
                  tag     = "div",
                  attr    = { class = "cathead" },
                  content = heading
                }
                for i, initiative in ipairs(entries) do
                  ui.container{
                    attr = {
                      class = "movable",
                      id = "entry_" .. tostring(initiative.id)
                    },
                    content = function()
                      local initiators_selector = initiative:get_reference_selector("initiating_members")
                        :add_where("accepted")
                      local initiators = initiators_selector:exec()
                      local initiator_names = {}
                      for i, initiator in ipairs(initiators) do
                        initiator_names[#initiator_names+1] = initiator.name
                      end
                      local initiator_names_string = table.concat(initiator_names, ", ")
                      ui.container{
                        attr = { style = "float: right;" },
                        content = function()
                          ui.link{
                            attr = { class = "clickable" },
                            content = _"Show",
                            module = "initiative",
                            view = "show",
                            id = initiative.id
                          }
                          slot.put(" ")
                          ui.link{
                            attr = { class = "clickable", target = "_blank" },
                            content = _"(new window)",
                            module = "initiative",
                            view = "show",
                            id = initiative.id
                          }
                          if not readonly then
                            slot.put(" ")
                            ui.image{ attr = { class = "grabber" }, static = "icons/grabber.png" }
                          end
                        end
                      }
                      if not readonly then
                        ui.container{
                          attr = { style = "float: left;" },
                          content = function()
                            ui.tag{
                              tag = "input",
                              attr = {
                                onclick = "voting_moveUp(this.parentNode.parentNode); return(false);",
                                name = "move_up",
                                value = initiative.id,
                                class = not disabled and "clickable" or nil,
                                type = "image",
                                src = encode.url{ static = "icons/move_up.png" },
                                alt = _"Move up"
                              }
                            }
                            slot.put("&nbsp;")
                            ui.tag{
                              tag = "input",
                              attr = {
                                onclick = "voting_moveDown(this.parentNode.parentNode); return(false);",
                                name = "move_down",
                                value = initiative.id,
                                class = not disabled and "clickable" or nil,
                                type = "image",
                                src = encode.url{ static = "icons/move_down.png" },
                                alt = _"Move down"
                              }
                            }
                            slot.put("&nbsp;")
                          end
                        }
                      end
                      ui.container{
                        content = function()
                          slot.put(encode.html(initiative.shortened_name))
                          if #initiators > 1 then
                            ui.container{
                              attr = { style = "font-size: 80%;" },
                              content = _"Initiators" .. ": " .. initiator_names_string
                            }
                          else
                            ui.container{
                              attr = { style = "font-size: 80%;" },
                              content = _"Initiator" .. ": " .. initiator_names_string
                            }
                          end
                        end
                      }
                    end
                  }
                end
              end
            }
          end
        end
      end
    }
    if not readonly then
      ui.tag{
        tag = "input",
        attr = {
          type = "submit",
          class = "voting_done",
          value = _"Finish voting"
        }
      }
    end
  end
}



local warning_text = _"Some JavaScript based functions (voting in particular) will not work.\nFor this beta, please use a current version of Firefox, Safari, Opera(?), Konqueror or another (more) standard compliant browser.\nAlternative access without JavaScript will be available soon."

ui.script{ static = "js/browser_warning.js" }
ui.script{ script = "checkBrowser(" .. encode.json(_"Your web browser is not fully supported yet." .. " " .. warning_text:gsub("\n", "\n\n")) .. ");" }

ui.tag{
  tag = "noscript",
  content = function()
    slot.put(_"JavaScript is disabled or not available." .. " " .. encode.html_newlines(warning_text))
  end
}


local issue = Issue:by_id(param.get("issue_id"), atom.integer)

local initiatives = issue.initiatives

local min_grade = -1;
local max_grade = 1;

for i, initiative in ipairs(initiatives) do
  -- TODO performance
  initiative.vote = Vote:by_pk(initiative.id, app.session.member.id)
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
end)

util.help("vote.list", _"Voting")


slot.put('<script src="' .. request.get_relative_baseurl() .. 'static/js/dragdrop.js"></script>')
slot.put('<script src="' .. request.get_relative_baseurl() .. 'static/js/voting.js"></script>')

ui.form{
  attr = { id = "voting_form" },
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
    slot.put('<input type="hidden" name="scoring" value=""/>')
    -- TODO abstrahieren
    ui.tag{
      tag = "input",
      attr = {
        type = "button",
        class = "voting_done",
        value = _"Finish voting"
      }
    }
    ui.container{
      attr = { id = "voting" },
      content = function()
        for grade = max_grade, min_grade, -1 do 
          local section = sections[grade]
          local class
          if grade > 0 then
            class = "approval"
          elseif grade < 0 then
            class = "disapproval"
          else
            class = "abstention"
          end
          ui.container{
            attr = { class = class },
            content = function()
              slot.put('<div class="cathead"></div>')
              for i, initiative in ipairs(section) do
                ui.container{
                  attr = {
                    class = "movable",
                    id = "entry_" .. tostring(initiative.id)
                  },
                  content = function()
                    local initiators = initiative.initiating_members
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
                        slot.put(" ")
                        ui.image{ attr = { class = "grabber" }, static = "icons/grabber.png" }
                      end
                    }
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
            end
          }
        end
      end
    }
    ui.tag{
      tag = "input",
      attr = {
        type = "button",
        class = "voting_done",
        value = _"Finish voting"
      }
    }
  end
}



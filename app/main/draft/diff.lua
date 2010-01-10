slot.put_into("title", _"Diff")

local old_draft_id = param.get("old_draft_id", atom.integer)
local new_draft_id = param.get("new_draft_id", atom.integer)

if not old_draft_id or not new_draft_id then
  slot.put( _"Please choose two versions of the draft to compare")
  return
end

if old_draft_id == new_draft_id then
  slot.put( _"Please choose two different versions of the draft to compare")
  return
end

if old_draft_id > new_draft_id then
  local tmp = old_draft_id
  old_draft_id = new_draft_id
  new_draft_id = tmp
end

local old_draft = Draft:by_id(old_draft_id)
local new_draft = Draft:by_id(new_draft_id)

local key = multirand.string(26, "123456789bcdfghjklmnpqrstvwxyz");

local old_draft_filename = encode.file_path(request.get_app_basepath(), 'tmp', "diff-" .. key .. "-old.tmp")
local new_draft_filename = encode.file_path(request.get_app_basepath(), 'tmp', "diff-" .. key .. "-new.tmp")

local old_draft_file = assert(io.open(old_draft_filename, "w"))
old_draft_file:write(old_draft.content)
old_draft_file:write("\n")
old_draft_file:close()

local new_draft_file = assert(io.open(new_draft_filename, "w"))
new_draft_file:write(new_draft.content)
new_draft_file:write("\n")
new_draft_file:close()

local output, err, status = os.pfilter(nil, "sh", "-c", "diff -U 100000 '" .. old_draft_filename .. "' '" .. new_draft_filename .. "' | grep -v ^--- | grep -v ^+++ | grep -v ^@")

os.remove(old_draft_filename)
os.remove(new_draft_filename)

if not status then
  ui.field.text{ value = _"The drafts do not differ" }
else
  slot.put('<table class="diff">')
  slot.put('<tr><th width="50%">' .. _"Old draft revision" .. '</th><th width="50%">' .. _"New draft revision" .. '</th></tr>')
  local last_state = "unchanged"
  local lines = {}
  local removed_lines = nil
  output = output .. " "
  output = output:gsub("[^\n\r]+", function(line)
    local state = "unchanged"
    local char = line:sub(1,1)
    line = line:sub(2)
    state = "unchanged"
    if char == "-" then
      state = "-"
    elseif char == "+" then
      state = "+"
    end
    if last_state == "unchanged" then
      if state == "unchanged" then
        lines[#lines+1] = line
      elseif (state == "-") or (state == "+") then
        local text = table.concat(lines, "<br />")
        slot.put("<tr><td>", text, "</td><td>", text, "</td></tr>")
        lines = { line }
      end
    elseif last_state == "-" then
      if state == "-" then
        lines[#lines+1] = line
      elseif state == "+" then
        removed_lines = lines
        lines = { line }
      elseif state == "unchanged" then
        local text = table.concat(lines,"<br />")
        slot.put('<tr><td class="removed">', text, "</td><td></td></tr>")
        lines = { line }
      end
    elseif last_state == "+" then
      if state == "+" then
        lines[#lines+1] = line
      elseif (state == "-") or (state == "unchanged") then
        if removed_lines then
          local text = table.concat(lines, "<br />")
          local removed_text = table.concat(removed_lines, "<br />")
          slot.put('<tr><td class="removed">', removed_text, '</td><td class="added">', text, "</td></tr>")
        else
          local text = table.concat(lines, "<br />")
          slot.put('<tr><td></td><td class="added">', text, "</td></tr>")
        end
        removed_lines = nil
        lines = { line }
      end
    end
    last_state = state
  end)
  slot.put("</table>")
end 


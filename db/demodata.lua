#!/usr/bin/env lua

member_count = 10000
area_count = 24
issue_count = 1000
policy_count = 3  -- do not change

function write(...)
  io.stdout:write(...)
end
function writeln(...)
  write(...)
  write("\n")
end

math.randomseed(os.time())

writeln('BEGIN;')

for i = 2, member_count do
  writeln('INSERT INTO "member" ("login", "name", "ident_number") VALUES (', "'testuser", i, "', 'Benutzer #", i, "', 'TEST", i, "');")
end

for i = 1, member_count do
  local is_linked = {}
  while math.random(4) > 1 do
    local k = math.random(member_count)
    if not is_linked[k] then
      local public = math.random(2) == 1 and "TRUE" or "FALSE"
      writeln('INSERT INTO "contact" ("member_id", "other_member_id", "public") VALUES (', i, ", ", k, ", ", public, ");")
      is_linked[k] = true
    end
  end
end

for i = 2, area_count do
  writeln('INSERT INTO "area" ("name") VALUES (', "'Area #", i, "');")
end

local memberships = {}

for i = 1, area_count do
  memberships[i] = {}
  for j = 1, member_count do
    if math.random(4) == 1 then
      memberships[i][j] = true
      local autoreject = math.random(2) == 1 and "TRUE" or "FALSE"
      writeln('INSERT INTO "membership" ("member_id", "area_id", "autoreject") VALUES (', j, ", ", i, ", ", autoreject, ");")
    end
  end
end

do
  local issue_initiative_count = {}
  local initiative_draft_count = {}
  local initiative_idx = 1
  local draft_count = 0
  for i = 1, issue_count do
    local area = math.random(area_count)
    writeln('INSERT INTO "issue" ("area_id", "policy_id") VALUES (', area, ", ", math.random(policy_count), ");")
    issue_initiative_count[i] = 1
    while math.random(3) > 1 do
      issue_initiative_count[i] = issue_initiative_count[i] + 1
    end
    for j = 1, issue_initiative_count[i] do
      writeln('INSERT INTO "initiative" ("issue_id", "name") VALUES (', i, ", 'Initiative #", initiative_idx, "');")
      initiative_draft_count[i] = 1
      while math.random(4) > 1 do
        initiative_draft_count[i] = initiative_draft_count[i] + 1
      end
      local initiators = {}
      local is_used = {}
      repeat
        local member = math.random(member_count)
        if not is_used[member] then
          initiators[#initiators+1] = member
          is_used[member] = true
        end
      until math.random(2) == 1
      for k = 1, initiative_draft_count[i] do
        draft_count = draft_count + 1
        writeln('INSERT INTO "draft" ("initiative_id", "author_id", "content") VALUES (', initiative_idx, ", ", initiators[math.random(#initiators)], ", 'Lorem ipsum... (#", draft_count, ")');")
      end
      for k = 1, #initiators do
        local member = math.random(member_count)
        writeln('INSERT INTO "initiator" ("member_id", "initiative_id") VALUES (', initiators[k], ", ", initiative_idx, ");")
        if math.random(50) > 1 then
          writeln('INSERT INTO "supporter" ("member_id", "initiative_id", "draft_id") VALUES (', initiators[k], ", ", initiative_idx, ", ", draft_count - math.random(initiative_draft_count[i]) + 1, ");")
        end
      end
      local probability = math.random(99) + 1
      for k = 1, member_count do
        if not is_used[k] and (memberships[area][k] and math.random(probability) <= 4 or math.random(probability) == 1) then
          writeln('INSERT INTO "supporter" ("member_id", "initiative_id", "draft_id") VALUES (', k, ", ", initiative_idx, ", ", draft_count - math.random(initiative_draft_count[i]) + 1, ");")
        end
      end
      initiative_idx = initiative_idx + 1
    end
  end
end

writeln('END;')

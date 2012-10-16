--[[--
Import members from CSV file

- Not yet existing members will be created.
- Existing members will get their privileges updated.
- Remaining imported members will be locked and deactivated.
- Privileges for not existing units will be ignored.

Format of the CSV file:
Line: "<invite_code>";"<unit_name>";"<unit_name>";"<unit_name>" ...
Charset: UTF-8

Usage:
$ su www-data
$ cd <path>/liquid_feedback_frontend
$ echo "util.import_members('<csv_file>')" | ../webmcp/bin/webmcp_shell myconfig

Location of this script should be: <path>/liquid_feedback_frontend/env/util/import_members.lua
--]]--


function util.import_members(file)

  -- translate unit names to ids
  local unit_map = {}
  local function unit_by_name(name)
    -- get from cache
    if unit_map[name] then
      return unit_map[name]
    end
    -- get from db
    local unit = Unit:new_selector()
      :add_where{ '"name" = ?', name }
      :optional_object_mode()
      :exec()
    if unit then
      unit_map[name] = unit.id
      return unit.id
    end
    -- unit does not exist
    unit_map[name] = false
    return false
  end

  -- to distinguish between imported and manually created members;
  -- needed for deactivation of remaining imported members
  local identification_prefix = "import-"

  -- get all imported members
  local member_remains = {}
  local imported_members = Member:new_selector()
    :add_where{ "member.identification LIKE ?", identification_prefix .. "%" }
    :add_where{ "member.locked = FALSE" }
    :exec()
  for i, member in ipairs(imported_members) do
    member_remains[member.id] = true
  end
  --print("Existing not locked imported members: " .. #member_remains)

  local fp = assert(io.open(file))
  for line in fp:lines() do

    -- extract invite code
    local invite_code = line:match('^"([^"]+)";')
    if not invite_code then
      print("No invite code could be extracted from this line: " .. line)
    else

      -- extract units
      local unit_assigned = {}
      local unit_names = {}
      for value in line:gmatch(';"([^"]+)"') do
        unit_names[#unit_names+1] = value
        local unit_id = unit_by_name(value)
        if unit_id then
          unit_assigned[unit_id] = true
        end
      end
      if #unit_names == 0 then
        print("No units could be extracted from this line: " .. line)
      end

      local identification = identification_prefix .. invite_code

      -- insert member
      local selector = Member:new_selector()
        :add_where{ '"identification" = ?', identification }
        :optional_object_mode()
      local member = selector:exec()
      if not member then
        --print("Insert member " .. identification)
        member = Member:new()
        member.identification = identification
        member.invite_code    = invite_code
        local err = member:try_save()
        if err then
          print("Database error: " .. tostring(err.message))
          db_error:escalate()
        end
      end

      -- member does not remain anymore
      member_remains[member.id] = false

      -- update unit vote privileges
      local units = Unit:new_selector()
        :add_field("privilege.member_id NOTNULL", "privilege_exists")
        :add_field("privilege.voting_right", "voting_right")
        :left_join("privilege", nil, { "privilege.member_id = ? AND privilege.unit_id = unit.id", member.id })
        :exec()
      for i, unit in ipairs(units) do
        if unit_assigned[unit.id] then
          if not unit.privilege_exists then
            -- add privilege
            local privilege = Privilege:new()
            privilege.unit_id = unit.id
            privilege.member_id = member.id
            privilege.voting_right = true
            privilege:save()
          end
        else
          if unit.privilege_exists then
            -- remove privilege
            local privilege = Privilege:by_pk(unit.id, member.id)
            privilege:destroy()
          end
        end
      end

    end

  end

  -- deactivate remaining imported members
  for id in pairs(member_remains) do
    if member_remains[id] then
      local member = Member:by_id(id)
      --print("Deactivate member " .. member.identification)
      member.locked = true
      member.active = false
      member:save()
    end
  end

end
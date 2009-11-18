slot.select("delegation", function()

  local delegation
  local area_id
  local issue_id

  local scope = "global"

  if param.get("initiative_id", atom.integer) then
    issue_id = Initiative:by_id(param.get("initiative_id", atom.integer)).issue_id
    scope = "issue"
  end

  if param.get("issue_id", atom.integer) then
    issue_id = param.get("issue_id", atom.integer)
    scope = "issue"
  end

  if param.get("area_id", atom.integer) then
    area_id = param.get("area_id", atom.integer)
    scope = "area"
  end



  local delegation

  if issue_id then
    delegation = Delegation:by_pk(app.session.member.id, nil, issue_id)
    if not delegation then
      local issue = Issue:by_id(issue_id)
      delegation = Delegation:by_pk(app.session.member.id, issue.area_id)
    end
  elseif area_id then
    delegation = Delegation:by_pk(app.session.member.id, area_id)
  end

  if not delegation then
    delegation = Delegation:by_pk(app.session.member.id)
  end
  if delegation then
    ui.container{
      attr = {
        class = "head",
        style = "cursor: pointer;",
        onclick = "document.getElementById('delegation_content').style.display = 'block';"
      },
      content = _"Your vote is delegated. [more]"
    }
    ui.container{
      attr = { class = "content", id = "delegation_content" },
      content = function()

        local delegation_chain = db:query{ "SELECT * FROM delegation_chain(?, ?, ?) JOIN member ON member.id = member_id ORDER BY index", app.session.member.id, area_id, issue_id }

        for i, record in ipairs(delegation_chain) do
          local style
          if record.participation then
            style = "font-weight: bold;"
          end
          if record.overridden then
            style = "color: #777;"
          end
          if not record.active then
            style = "text-decoration: line-through;"
          end
          if record.scope_in then
            ui.field.text{
              value = " v " .. record.scope_in .. " v "
            }
          end
          local name = record.name
          if record.member_id == app.session.member.id then
            name = _"Me"
          end
          ui.field.text{
            attr = { style = style },
            value = name
          }
        end

        ui.link{
          attr = { class = "revoke" },
          content = function()
            ui.image{ static = "icons/16/delete.png" }
            slot.put(_"Revoke")
          end,
          module = "delegation",
          action = "update",
          params = { issue_id = delegation.issue_id, area_id = delegation.area_id, delete = true },
          routing = {
            default = {
              mode = "redirect",
              module = request.get_module(),
              view = request.get_view(),
              id = param.get_id_cgi(),
              params = param.get_all_cgi()
            }
          }
        }

        ui.container{
          attr = {
            class = "head",
            style = "cursor: pointer;",
            onclick = "document.getElementById('delegation_content').style.display = 'none';"
          },
          content = _"Click here to close."
        }
      end
    }
  end

end)

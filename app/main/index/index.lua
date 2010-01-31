slot.select("title", function()
  if app.session.member then
    execute.view{
      module = "member_image",
      view = "_show",
      params = {
        member = app.session.member,
        image_type = "avatar"
      }
    }
  end
end)

slot.select("title", function()
  ui.container{
    attr = { class = "lang_chooser" },
    content = function()
      for i, lang in ipairs{"en", "de", "eo"} do
        ui.link{
          content = function()
            ui.image{
              static = "lang/" .. lang .. ".png",
              attr = { style = "margin-left: 0.5em;", alt = lang }
            }
          end,
          module = "index",
          action = "set_lang",
          params = { lang = lang },
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
      end
    end
  }
end)

slot.put_into("title", encode.html(config.app_title))

slot.select("actions", function()

  if app.session.member then
    ui.link{
      content = function()
          ui.image{ static = "icons/16/application_form.png" }
          slot.put(_"Edit my profile")
      end,
      module = "member",
      view = "edit"
    }
  
    ui.link{
      content = function()
          ui.image{ static = "icons/16/user_gray.png" }
          slot.put(_"Upload images")
      end,
      module = "member",
      view = "edit_images"
    }
  
    execute.view{
      module = "delegation",
      view = "_show_box"
    }
  
    ui.link{
      content = function()
          ui.image{ static = "icons/16/wrench.png" }
          slot.put(_"Settings")
      end,
      module = "member",
      view = "settings"
    }
  
    if config.download_dir then
      ui.link{
        content = function()
            ui.image{ static = "icons/16/database_save.png" }
            slot.put(_"Download")
        end,
        module = "index",
        view = "download"
      }
    end 
  end
end)

local lang = locale.get("lang")
local basepath = request.get_app_basepath() 
local file_name = basepath .. "/locale/motd/" .. lang .. ".txt"
local file = io.open(file_name)
if file ~= nil then
  local help_text = file:read("*a")
  if #help_text > 0 then
    ui.container{
      attr = { class = "motd wiki" },
      content = function()
        slot.put(format.wiki_text(help_text))
      end
    }
  end
end


util.help("index.index", _"Home")

local areas = {}
if app.session.member then
  local selector = Area:new_selector()
    :reset_fields()
    :add_field("area.id", nil, { "grouped" })
    :add_field("area.name", nil, { "grouped" })
    :add_field("membership.member_id NOTNULL", "is_member", { "grouped" })
    :add_field("count(issue.id)", "issues_to_vote_count")
    :add_field("count(interest.member_id)", "interested_issues_to_vote_count")
    :join("issue", nil, "issue.area_id = area.id AND issue.fully_frozen NOTNULL AND issue.closed ISNULL")
    :left_join("direct_voter", nil, { "direct_voter.issue_id = issue.id AND direct_voter.member_id = ?", app.session.member.id })
    :add_where{ "direct_voter.member_id ISNULL" }
    :left_join("interest", nil, { "interest.issue_id = issue.id AND interest.member_id = ?", app.session.member.id })
    :left_join("membership", nil, { "membership.area_id = area.id AND membership.member_id = ? ", app.session.member.id })
  
  for i, area in ipairs(selector:exec()) do
    if area.is_member or area.interested_issues_to_vote_count > 0 then
      areas[#areas+1] = area
    end
  end
end

if #areas > 0 then
  ui.container{
    attr = { style = "font-weight: bold;" },
    content = _"Current votings in areas you are member of and issues you are interested in:"
  }
  
  ui.list{
    records = areas,
    columns = {
      {
        name = "name"
      },
      {
        content = function(record)
          if record.is_member and record.issues_to_vote_count > 0 then
            ui.link{
              content = function()
                if record.issues_to_vote_count > 1 then
                  slot.put(_("#{issues_to_vote_count} issue(s)", { issues_to_vote_count = record.issues_to_vote_count }))
                else
                  slot.put(_("One issue"))
                end
              end,
              module = "area",
              view = "show",
              id = record.id,
              params = { 
                filter = "frozen",
                filter_voting = "not_voted"
              }
            }
          else
            slot.put(_"Not a member")
          end
        end
      },
      {
        content = function(record)
          if record.interested_issues_to_vote_count > 0 then
            ui.link{
              content = function()
                if record.interested_issues_to_vote_count > 1 then
                  slot.put(_("#{interested_issues_to_vote_count} issue(s) you are interested in", { interested_issues_to_vote_count = record.interested_issues_to_vote_count }))
                else
                  slot.put(_"One issue you are interested in")
                end
              end,
              module = "area",
              view = "show",
              id = record.id,
              params = { 
                filter = "frozen",
                filter_interest = "my",
                filter_voting = "not_voted"
              }
            }
          end
        end
      },
    }
  }
end

local initiatives_selector = Initiative:new_selector()
  :join("initiator", nil, { "initiator.initiative_id = initiative.id AND initiator.member_id = ? AND initiator.accepted ISNULL", app.session.member.id })

if initiatives_selector:count() > 0 then
  ui.container{
    attr = { style = "font-weight: bold;" },
    content = _"Initiatives that invited you to become initiator:"
  }

  execute.view{
    module = "initiative",
    view = "_list",
    params = { initiatives_selector = initiatives_selector }
  }
end


if app.session.member then
  execute.view{
    module = "member",
    view = "_show",
    params = { member = app.session.member }
  }
end

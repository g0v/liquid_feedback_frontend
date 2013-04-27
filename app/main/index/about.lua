ui.title(_"About site")
app.html_title.title = _"About site"

if app.session.member_id and config.use_terms then
  ui.actions(function()
    ui.link{
      module = "index",
      view = "usage_terms",
      text = _"Terms of use"
    }
  end)
end


ui.heading{ level = 2, attr = { class = "about" }, content = _"This service is provided by:" }
slot.put(config.app_service_provider)

ui.heading{ level = 2, attr = { class = "about" }, content = _"This service is provided using the following software components:" }

local tmp = {
  -- references to LiquidFeedback removed on demand of its authors
  {
    name = "Pirate Feedback",
    url = "http://wiki.piratenpartei.de/Pirate_Feedback",
    version = config.pirate_feedback_version,
    license = "GPL",
    license_url = "http://www.gnu.org/licenses/old-licenses/gpl-2.0"
  },
  {
    name = "Lua",
    url = "http://www.lua.org",
    version = _VERSION:gsub("Lua ", ""),
    license = "MIT/X11",
    license_url = "http://www.lua.org/license.html"
  },
  {
    name = "PostgreSQL",
    url = "http://www.postgresql.org/",
    version = db:query("SELECT version();")[1].version:gsub("PostgreSQL ", ""):gsub("on.*", ""),
    license = "BSD",
    license_url = "http://www.postgresql.org/about/licence"
  },
}

ui.list{
  records = tmp,
  columns = {
    {
      label = _"Software",
      content = function(record)
        ui.link{
          content = record.name,
          external = record.url
        }
      end
    },
    {
      label = _"Version",
      content = function(record) ui.field.text{ value = record.version } end
    },
    {
      label = _"License",
      content = function(record)
        ui.link{
          content = record.license,
          external = record.license_url
        }
      end
    }
  }
}

ui.heading{ level = 2, attr = { class = "about" }, content = "3rd party license information:" }
slot.put('The icons used in Pirate Feedback are from <a href="http://www.famfamfam.com/lab/icons/silk/">Silk icon set 1.3</a> by Mark James. His work is licensed under a <a href="http://creativecommons.org/licenses/by/2.5/">Creative Commons Attribution 2.5 License.</a>')

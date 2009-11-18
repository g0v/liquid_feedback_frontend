config.app_name = "LiquidFeedback"
config.app_version = "alpha1"

config.app_title = config.app_name .. " (" .. request.get_config_name() .. " environment)"

config.app_service_provider = "Snake Oil<br/>10000 Berlin<br/>Germany"

-- uncomment the following two lines to use C implementations of chosen
-- functions and to disable garbage collection during the request, to
-- increase speed:
--
-- require 'webmcp_accelerator'
-- collectgarbage("stop")

-- open and set default database handle
db = assert(mondelefant.connect{
  engine='postgresql',
  dbname='liquid_feedback'
})
at_exit(function() 
  db:close()
end)
function mondelefant.class_prototype:get_db_conn() return db end

-- enable output of SQL commands in trace system
function db:sql_tracer(command)
  return function(error_info)
    local error_info = error_info or {}
    trace.sql{ command = command, error_position = error_info.position }
  end
end

-- 'request.get_relative_baseurl()' should be replaced by the absolute
-- base URL of the application, as otherwise HTTP redirects will not be
-- standard compliant
request.set_absolute_baseurl(request.get_relative_baseurl())




-- get record by id
function mondelefant.class_prototype:by_id(id)
  local selector = self:new_selector()
  selector:add_where{ 'id = ?', id }
  selector:optional_object_mode()
  return selector:exec()
end


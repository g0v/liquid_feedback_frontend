-- ========================================================================
-- DO NOT CHANGE ANYTHING IN THIS FILE
-- (except when you really know what you are doing!)
-- ========================================================================


config.app_version = "2.beta12"

if not config.instance_name then
  config.instance_name = request.get_config_name()
end

if
  not config.app_service_provider or
  not config.use_terms or
  not config.use_terms_checkboxes
then
  error("Missing mandatory config option")
end

if config.enabled_languages == nil then
  config.enabled_languages = { 'en', 'de', 'eo', 'el', 'hu' }
end

if config.default_lang == nil then
  config.default_lang = "en"
end

if config.mail_subject_prefix == nil then
  config.mail_subject_prefix = "[LiquidFeedback] "
end

if config.absolute_base_url == nil then
  config.absolute_base_url = request.get_relative_baseurl()
end

if config.member_image_content_type == nil then
  config.member_image_content_type = "image/jpeg"
end

if config.member_image_convert_func == nil then
  config.member_image_convert_func = {
    avatar = function(data) return extos.pfilter(data, "convert", "jpeg:-", "-thumbnail",   "48x48", "jpeg:-") end,
    photo =  function(data) return extos.pfilter(data, "convert", "jpeg:-", "-thumbnail", "240x240", "jpeg:-") end
  }
end

if config.public_access == nil then
  config.public_access = "full"
end

if config.locked_profile_fields == nil then
  config.locked_profile_fields = {}
end

if not config.database then
  config.database = { engine='postgresql', dbname='liquid_feedback' }
end

request.set_404_route{ module = 'index', view = '404' }

-- open and set default database handle
db = assert(mondelefant.connect(config.database))
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

request.set_absolute_baseurl(config.absolute_base_url)


-- TODO abstraction
-- get record by id
function mondelefant.class_prototype:by_id(id)
  local selector = self:new_selector()
  selector:add_where{ 'id = ?', id }
  selector:optional_object_mode()
  return selector:exec()
end


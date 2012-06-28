-- ========================================================================
-- MANDATORY CONFIG OPTIONS (MUST BE SET!)
-- ========================================================================

-- Information about service provider (HTML)
-- ------------------------------------------------------------------------
config.app_service_provider = "Snake Oil<br/>10000 Berlin<br/>Germany"

-- A rocketwiki formatted text the user has to accept while registering
-- ------------------------------------------------------------------------
config.use_terms = "=== Terms of Use ==="

-- Checkbox(es) the user has to accept while registering
-- ------------------------------------------------------------------------
config.use_terms_checkboxes = {
  {
    name = "terms_of_use_v1",
    html = "I accept the terms of use.",
    not_accepted_error = "You have to accept the terms of use to be able to register."
  },
--  {
--    name = "extra_terms_of_use_v1",
--    html = "I accept the extra terms of use.",
--    not_accepted_error = "You have to accept the extra terms of use to be able to register."
--  }
}

-- ========================================================================
-- Optional config options
-- Remove leading -- to enable a option
-- ========================================================================

-- Name of this instance, defaults to name of config file
-- ------------------------------------------------------------------------
-- config.instance_name = "Instance name"

-- Connection information for the LiquidFeedback database
-- ------------------------------------------------------------------------
-- config.database = { engine='postgresql', dbname='liquid_feedback' }

-- Absolute base url of application
-- ------------------------------------------------------------------------
-- config.absolute_base_url = "http://example.com/"

-- List of enabled languages, defaults to available languages
-- ------------------------------------------------------------------------
-- config.enabled_languages = { 'en', 'de', 'eo', 'el', 'hu' }

-- Default language, defaults to "en"
-- ------------------------------------------------------------------------
-- config.default_lang = "en"

-- after how long is a user considered inactive and the trustee will see warning,
-- notation is according to postgresql intervals, default: no warning at all
-- ------------------------------------------------------------------------
-- config.delegation_warning_time = '6 months'

-- Prefix of all automatic mails, defaults to "[Liquid Feedback] "
-- ------------------------------------------------------------------------
-- config.mail_subject_prefix = "[LiquidFeedback] "

-- Sender of all automatic mails, defaults to system defaults
-- ------------------------------------------------------------------------
-- config.mail_envelope_from = "liquid-support@example.com"
-- config.mail_from = "LiquidFeedback"
-- config.mail_reply_to = "liquid-support@example.com"

-- Supply custom url for avatar/photo delivery
-- ------------------------------------------------------------------------
-- config.fastpath_url_func = nil

-- Local directory for database dumps offered for download
-- ------------------------------------------------------------------------
-- config.download_dir = nil

-- Special use terms for database dump download
-- ------------------------------------------------------------------------
-- config.download_use_terms = "=== Download use terms ===\n"

-- Set public access level
-- Available options: false, "anonymous", "pseudonym", "full"
-- Defaults to "full"
-- ------------------------------------------------------------------------
-- config.public_access = "full"

-- Use custom image conversion, defaults to ImageMagick's convert
-- ------------------------------------------------------------------------
--config.member_image_content_type = "image/jpeg"
--config.member_image_convert_func = {
--  avatar = function(data) return extos.pfilter(data, "convert", "jpeg:-", "-thumbnail",   "48x48", "jpeg:-") end,
--  photo =  function(data) return extos.pfilter(data, "convert", "jpeg:-", "-thumbnail", "240x240", "jpeg:-") end
--}

-- Integration of Etherpad, disabled by default
-- ------------------------------------------------------------------------
--config.etherpad = {
--  base_url = "http://example.com:9001/",
--  api_base = "http://localhost:9001/",
--  api_key = "mysecretapikey",
--  group_id = "mygroupname",
--  cookie_path = "/"
--}

-- WebMCP accelerator
-- uncomment the following two lines to use C implementations of chosen
-- functions and to disable garbage collection during the request, to
-- increase speed:
-- ------------------------------------------------------------------------
-- require 'webmcp_accelerator'
-- collectgarbage("stop")


-- ========================================================================
-- Do main initialisation (DO NOT REMOVE FOLLOWING SECTION)
-- ========================================================================

execute.config("init")

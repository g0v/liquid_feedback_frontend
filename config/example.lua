-- ========================================================================
-- MANDATORY (MUST BE CAREFULLY CHECKED AND PROPERLY SET!)
-- ========================================================================

-- Name of this instance, defaults to name of config file
-- ------------------------------------------------------------------------
config.instance_name = "Instance name"


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


-- Absolute base url of application
-- ------------------------------------------------------------------------
config.absolute_base_url = "http://example.com/"


-- Connection information for the Pirate Feedback database
-- ------------------------------------------------------------------------
config.database = { engine='postgresql', dbname='pirate_feedback' }


-- Location of the rocketwiki binaries
-- ------------------------------------------------------------------------
config.formatting_engine_executeables = {
  rocketwiki= "/opt/rocketwiki-lqfb/rocketwiki-lqfb",
  compat = "/opt/rocketwiki-lqfb/rocketwiki-lqfb-compat"
}


-- Public access level
-- ------------------------------------------------------------------------
-- Available options:
-- "none"
--     -> Closed user group, no public access at all
--        (except login/registration/password reset)
-- "anonymous"
--     -> Shows only initiative/suggestions texts and aggregated
--        supporter/voter counts
-- "authors_pseudonymous"
--     -> Like anonymous, but shows screen names of authors
-- "all_pseudonymous"
--     -> Show everything a member can see, except profile pages
-- "everything"
--     -> Show everything a member can see, including profile pages
-- ------------------------------------------------------------------------
config.public_access = "none"



-- ========================================================================
-- OPTIONAL
-- Remove leading -- to use a option
-- ========================================================================

-- List of enabled languages, defaults to available languages
-- ------------------------------------------------------------------------
-- config.enabled_languages = { 'en', 'de', 'eo', 'el', 'hu', 'it', 'nl', 'zh-Hans', 'zh-TW' }

-- Default language, defaults to "en"
-- ------------------------------------------------------------------------
-- config.default_lang = "en"

-- after how long is a user considered inactive and the trustee will see warning,
-- notation is according to postgresql intervals, default: no warning at all
-- ------------------------------------------------------------------------
-- config.delegation_warning_time = '6 months'

-- Invite code expiry
-- after how long is an invite code can't be used anymore
-- notation is according to postgresql intervals
-- Default: no expiry
-- ------------------------------------------------------------------------
-- config.invite_code_expiry = '1 month'

-- Prefix of all automatic mails, defaults to "[Pirate Feedback] "
-- ------------------------------------------------------------------------
-- config.mail_subject_prefix = "[Pirate Feedback] "

-- Sender of all automatic mails, defaults to system defaults
-- ------------------------------------------------------------------------
-- config.mail_envelope_from = "pirate_feedback@example.com"
-- config.mail_from = { name = "Pirate Feedback", address = "pirate_feedback@example.com" }
-- config.mail_reply_to = { name = "Support", address = "support@example.com" }

-- Email for support
-- is displayed if an invite code is expired or if there is no confirmed email address to send a passwort reset link to
-- ------------------------------------------------------------------------
-- config.support = "support@example.com"

-- Supply custom url for avatar/photo delivery
-- ------------------------------------------------------------------------
-- Use the following option to enable fast image loading:
-- config.fastpath_url_func = function(member_id, image_type)
--   return request.get_absolute_baseurl() .. "fastpath/getpic?" .. tostring(member_id) .. "+" .. tostring(image_type)
-- end

-- Use custom image conversion, defaults to ImageMagick's convert
-- ------------------------------------------------------------------------
--config.member_image_content_type = "image/jpeg"
--config.member_image_convert_func = {
--  avatar = function(data) return extos.pfilter(data, "convert", "jpeg:-", "-thumbnail",   "48x48", "jpeg:-") end,
--  photo =  function(data) return extos.pfilter(data, "convert", "jpeg:-", "-thumbnail", "240x240", "jpeg:-") end
--}

-- WebMCP accelerator
-- uncomment the following two lines to use C implementations of chosen
-- functions and to disable garbage collection during the request, to
-- increase speed:
-- ------------------------------------------------------------------------
-- require 'webmcp_accelerator'
-- if cgi then collectgarbage("stop") end

-- Integration of Etherpad, disabled by default
-- ------------------------------------------------------------------------
--config.etherpad = {
--  base_url = "http://example.com:9001/",
--  api_base = "http://localhost:9001/",
--  api_key = "mysecretapikey",
--  group_id = "mygroupname",
--  cookie_path = "/"
--}

-- Automatic issue related discussion URL
-- ------------------------------------------------------------------------
-- config.issue_discussion_url_func = function(issue)
--   return "http://example.com/discussion/issue_" .. tostring(issue.id)
-- end

-- Absolute base of short url for short links
-- Default: disabled
-- ------------------------------------------------------------------------
-- config.absolute_base_short_url = "http://example.com/"

-- Local directory for database dumps offered for download
-- ------------------------------------------------------------------------
-- config.download_dir = nil

-- Special use terms for database dump download
-- ------------------------------------------------------------------------
-- config.download_use_terms = "=== Download use terms ===\n"

-- Display a message of the day once for each session
-- ------------------------------------------------------------------------
-- config.motd = "===Message of the day===\nThe MOTD is formatted with rocket wiki"

-- Display the message of the day not only to logged in members
-- ------------------------------------------------------------------------
-- config.motd_public = true

-- Trace debug
-- uncomment the following line to enable debug trace
-- ------------------------------------------------------------------------
-- config.enable_debug_trace = true

-- Registration without invite code (for demonstration purposes)
-- uncomment the following line to allow registration without an invite code
-- ------------------------------------------------------------------------
-- config.register_without_invite_code = true

-- Member import:
-- Maximum number of members which should be deactivated in one run
-- helps to avoid deactivating members by accident
-- Default: no limit
-- ------------------------------------------------------------------------
-- config.deactivate_max_members = 50

-- ========================================================================
-- Do main initialisation (DO NOT REMOVE FOLLOWING SECTION)
-- ========================================================================

execute.config("init")

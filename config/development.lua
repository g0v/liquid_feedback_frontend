config.absolute_base_url = "http://10.8.33.34/lf/"

execute.config("default")

config.formatting_engine_executeables = {
  rocketwiki= "/opt/rocketwiki/rocketwiki-lqfb",
  compat = "/opt/rocketwiki/rocketwiki-lqfb-compat"
}

config.mail_from = "LiquidFeedback"
config.mail_reply_to = "liquid-support@localhost"

config.issue_discussion_url_func = function(issue) return "http://example.com/issue_" .. tostring(issue.id) end

config.auth_openid_enabled = false
config.auth_openid_https_as_default = true

config.api_enabled = true

config.auth_openid_identifier_check_func = function(uri)
  local uri = uri:lower()
  if uri:find("^https://") then
    uri = uri:match("^https://(.*)")
  end
  if uri:find("^[0-9A-Za-z_-]+%.example%.com/?$") then
    return true
  else
    return false
  end
end

config.motd_public = "==Public motd=="

--config.motd_intern = "==Internal motd=="

config.public_access = "anonymous"

-- you can put some js code to the bottom on the page
-- here it opens the trace window

--slot.put_into(
--  "custom_script",
--  "document.getElementById('trace_show').onclick();"
--)

config.etherpad = {
  base_url = "http://localhost:9001/",
  api_base = "http://localhost:9001/",
  api_key = "g5XAVrRb5EgPuEqIdVrRNt2Juipx3PoH",
  group_id = "g.7WDKN3StkEyuWkyN",
  cookie_path = "/"
}

config.document_dir = "/home/dark/tmp"

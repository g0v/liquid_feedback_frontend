local user_supplied_identifier = param.get("openid_identifier")

if not config.auth_openid_identifier_check_func(user_supplied_identifier) then
  slot.put_into("error", _"This identifier is not allowed for this instance.")
  return
end

local success,errmsg = auth.openid.initiate{
  user_supplied_identifier = user_supplied_identifier,
  https_as_default         = config.auth_openid_https_as_default,
  curl_options             = config.auth_openid_curl_options,
  realm                    = request.get_absolute_baseurl(),
  return_to_module         = "openid",
  return_to_view           = "verify"
}

if not success then
  slot.put_into("error", encode.html(_("Error while resolving openid. Internal message: '#{errmsg}'", { errmsg = errmsg })))
  return false
end
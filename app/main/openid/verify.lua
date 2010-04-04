local claimed_identifier, errmsg = auth.openid.verify{
  force_https              = config.auth_openid_force_https,
  curl_options             = config.auth_openid_curl_options
}

if not claimed_identifier then
  slot.put_into("error", _"Sorry, it was not possible to verify your OpenID.")
  return
end

if not config.auth_openid_identifier_check_func(claimed_identifier) then
  slot.put_into("error", _"This identifier is not allowed for this instance.")
  return
end

slot.put("validated as: ", encode.html(claimed_identifier), "<br />")


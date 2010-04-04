if not config.auth_openid_enabled then
  error("OpenID is not enabled.")
end

execute.inner()

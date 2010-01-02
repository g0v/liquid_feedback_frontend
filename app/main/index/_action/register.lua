local invite_code = InviteCode:by_code(param.get("code"))

if not invite_code or invite_code.used then
  slot.put_into("error", _"The code you've entered is invalid")
  request.redirect{
    mode   = "forward",
    module = "index",
    view   = "register"
  }
  return false
end

local notify_email = param.get("notify_email")

if invite_code and not notify_email then
  request.redirect{
    mode   = "redirect",
    module = "index",
    view   = "register",
    params = { code = invite_code.code }
  }
  return false
end

if #notify_email < 5 then
  slot.put_into("error", _"Email address too short!")
  request.redirect{
    mode   = "redirect",
    module = "index",
    view   = "register",
    params = { code = invite_code.code }
  }
  return false
end

local name = param.get("name")

if notify_email and not name then
  request.redirect{
    mode   = "redirect",
    module = "index",
    view   = "register",
    params = {
      code = invite_code.code,
      notify_email = notify_email
    }
  }
  return false
end

name = util.trim(name)

if #name < 3 then
  slot.put_into("error", _"This username is too short!")
  request.redirect{
    mode   = "redirect",
    module = "index",
    view   = "register",
    params = {
      code = invite_code.code,
      notify_email = notify_email
    }
  }
  return false
end

if Member:by_name(name) then
  slot.put_into("error", _"This name is already taken, please choose another one!")
  request.redirect{
    mode   = "redirect",
    module = "index",
    view   = "register",
    params = {
      code = invite_code.code,
      notify_email = notify_email
    }
  }
  return false
end

local login = param.get("login")

if name and not login then
  request.redirect{
    mode   = "redirect",
    module = "index",
    view   = "register",
    params = { 
      code = invite_code.code,
      notify_email = notify_email,
      name = name
    }
  }
  return false
end

login = util.trim(login)

if #login < 3 then 
  slot.put_into("error", _"This login is too short!")
  request.redirect{
    mode   = "redirect",
    module = "index",
    view   = "register",
    params = { 
      code = invite_code.code,
      notify_email = notify_email,
      name = name
    }
  }
  return false
end

if Member:by_login(login) then 
  slot.put_into("error", _"This login is already taken, please choose another one!")
  request.redirect{
    mode   = "redirect",
    module = "index",
    view   = "register",
    params = { 
      code = invite_code.code,
      notify_email = notify_email,
      name = name
    }
  }
  return false
end

local use_terms_accepted = param.get("use_terms_accepted", atom.boolean)

if login and use_terms_accepted == nil then
  request.redirect{
    mode   = "redirect",
    module = "index",
    view   = "register",
    params = { 
      code = invite_code.code,
      notify_email = notify_email,
      name = name,
      login = login
    }
  }
  return false
end

if use_terms_accepted ~= true then
  slot.put_into("error", _"You have to accept the terms of use to complete registration.")
  request.redirect{
    mode   = "redirect",
    module = "index",
    view   = "register",
    params = { 
      code = invite_code.code,
      notify_email = notify_email,
      name = name,
      login = login
    }
  }
  return false
end

local password1 = param.get("password1")
local password2 = param.get("password2")

if login and not password1 then
  request.redirect{
    mode   = "redirect",
    module = "index",
    view   = "register",
    params = { 
      code = invite_code.code,
      notify_email = notify_email,
      name = name,
      login = login
    }
  }
  return false
end

if password1 ~= password2 then
  slot.put_into("error", _"Passwords don't match!")
  request.redirect{
    mode   = "redirect",
    module = "index",
    view   = "register",
    params = { 
      code = invite_code.code,
      notify_email = notify_email,
      name = name,
      login = login
    }
  }
  return false
end

if #password1 < 8 then
  slot.put_into("error", _"Passwords must consist of at least 8 characters!")
  request.redirect{
    mode   = "redirect",
    module = "index",
    view   = "register",
    params = { 
      code = invite_code.code,
      notify_email = notify_email,
      name = name,
      login = login
    }
  }
  return false
end

local member = Member:new()

member.login = login
member.name = name

local success = member:set_notify_email(notify_email)
if not success then
  slot.put_into("error", _"Can't send confirmation email")
  request.redirect{
    mode   = "redirect",
    module = "index",
    view   = "register",
    params = { 
      code = invite_code.code,
      notify_email = notify_email,
      name = name,
      login = login
    }
  }
  return
end

member:set_password(password1)
member:save()

invite_code.member_id = member.id
invite_code.used = "now"
invite_code:save()

slot.put_into("notice", _"You've successfully registered and you can login now with your login and password!")

request.redirect{
  mode   = "redirect",
  module = "index",
  view   = "login",
}

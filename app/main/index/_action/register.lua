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

local name = param.get("name")

if invite_code and not name then
  slot.put_into("notice", _"Invite code valid!")
  request.redirect{
    mode   = "redirect",
    module = "index",
    view   = "register",
    params = { code = invite_code.code }
  }
  return false
end

if Member:by_name(name) then
  slot.put_into("error", _"This name is already taken, please choose another one!")
  request.redirect{
    mode   = "redirect",
    module = "index",
    view   = "register",
    params = { code = invite_code.code }
  }
  return false
end

local login = param.get("login")

if name and not login then
  slot.put_into("notice", _"Name is available")
  request.redirect{
    mode   = "redirect",
    module = "index",
    view   = "register",
    params = { 
      code = invite_code.code,
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
      name = name
    }
  }
  return false
end

local password1 = param.get("password1")
local password2 = param.get("password2")

if login and not password1 then
  slot.put_into("notice", _"Login is available")
  request.redirect{
    mode   = "redirect",
    module = "index",
    view   = "register",
    params = { 
      code = invite_code.code,
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
      name = name,
      login = login
    }
  }
  return false
end

local member = Member:new()

member.login = login
member.name = name
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

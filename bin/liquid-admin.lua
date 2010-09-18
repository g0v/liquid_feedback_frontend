#!/usr/bin/env lua

OptionParser = require("utils.optparse")

COMMANDS = {{"setpwd <username> <password>", "Set a user command"}, 
            {"listuser", "List usernames"},
           }

t={usage="<some usage message>", version="<version string>", commands=COMMANDS}
op=OptionParser(t)
--op.add_option({"-t", action="safe_true", dest="test", help="<help message for this option>"})
op.add_option({"-c", action="store", dest="config", help="config name to use", default="default"})
op.add_option({"-w", action="store", dest="webmcp", help="path to webmcp", default="../webmcp"})

options,args = op.parse_args()

if #args == 0 then
    print("Error: command is required\n")
    op.print_help()
    return
end

-- dirty dirty dirty, dirty dirty, dirty dirty dow monkey patch env
if not os.setenv then

    local env, getenv = { }, os.getenv

    function os.setenv(k,v)
        env[k] = v
    end

    function os.getenv(k)
        return env[k] or getenv(k)
    end

end

-- detect current path FIXME: platform portable
local PWD = io.popen("pwd"):read()
os.setenv("WEBMCP_APP_BASEPATH", PWD)
os.setenv("WEBMCP_CONFIG_NAME", options.config)
os.setenv("WEBMCP_INTERACTIVE", "yes")

-- load webmcp framework
WEBMCP_PATH = options.webmcp .. "/framework/"
dofile(options.webmcp .. "/framework/cgi-bin/webmcp.lua")

function error(why)
    print(why)
    os.exit(2)
end

if args[1] == "setpwd" then
  if #args < 2 then
    error("login is required")
  end
  require("model.member")
  user = Member:by_login(args[2])
  if not user then
    error("User "..args[2].." not found")
  end
  print("Enter password:")
  password = io.read()
  if password then
    user:set_password(password)
    user:save()
  end
end

if args[1] == "listusers" then
  require("model.member")
  sel = Member:new_selector()
  users = sel:exec()
  --sel:optional_object_mode()
  print("Login                           Active")
  for i,v in pairs(users) do
    if v.login then
      print(v.login .. string.rep(" ", 25-#v.login), v.active)
    end
  end
end






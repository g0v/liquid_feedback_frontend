ui.title(_"Request login name")

ui.actions(function()
  ui.link{
    content = function()
      slot.put(_"Cancel")
    end,
    module = "index",
    view = "login"
  }
end)

if not config.send_login then
  slot.put_into("error", _"This function is not activated!")
  return false
end

ui.tag{
  tag = "p",
  content = _"Please enter your email address! You will receive an email with your login name."
}
ui.form{
  attr = { class = "vertical" },
  module = "index",
  action = "send_login",
  routing = {
    ok = {
      mode = "redirect",
      module = "index",
      view = "index"
    }
  },
  content = function()
    ui.field.text{
      label = _"Email address",
      name  = "email",
      value = param.get("email")
    }
    ui.submit{ text = _"Request email with login name" }
  end
}

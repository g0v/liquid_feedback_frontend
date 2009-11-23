local member = param.get("member", "table")

local name
if member.name_highlighted then
  name = encode.highlight(member.name_highlighted)
else
  name = encode.html(member.name)
end

ui.link{
  attr = { class = "member_thumb" },
  module = "member",
  view = "show",
  id = member.id,
  content = function()
    ui.image{
      attr = { width = 48, height = 48 },
      module    = "member",
      view      = "avatar",
      id        = member.id,
      extension = "jpg"
    }
    slot.put(name)
  end
}
local member = param.get("member", "table")
local image_type = param.get("image_type")
local show_dummy = param.get("show_dummy", atom.boolean)

local image = member:get_reference_selector("images")
  :add_where{ "image_type = ?", image_type }
  :optional_object_mode()
  :exec()
if image or show_dummy then
  if config.fastpath_url_func then
    ui.image{
      attr = { class = "member_image member_image_" .. image_type },
      external = config.fastpath_url_func(member.id, image_type)
    }
  else
    ui.image{
      attr = { class = "member_image member_image_" .. image_type },
      module = "member_image",
      view = "show",
      extension = "jpg",
      id = member.id,
      params = {
        image_type = image_type
      }
    }
  end
end

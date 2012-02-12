local member = param.get("member", "table")
local image_type = param.get("image_type")
local show_dummy = param.get("show_dummy", atom.boolean)
local class = param.get("class")
local popup_text = param.get("popup_text")

if class then
  class = " " .. class
else
  class = ""
end

local image = member:get_reference_selector("images")
  :add_where{ "image_type = ?", image_type }
  :optional_object_mode()
  :exec()

if image or show_dummy then
  if config.fastpath_url_func then
    ui.image{
      attr = { title = popup_text, class = "member_image member_image_" .. image_type .. class },
      external = config.fastpath_url_func(member.id, image_type)
    }
  else
    if not image then
      ui.image{
        attr = { title = popup_text, class = "member_image member_image_" .. image_type .. class },
        external = encode.url{ static = (config.member_image_default_file[image_type] or 'icons/16/lightning.png')},
      }
    else
      ui.image{
        attr = { title = popup_text, class = "member_image member_image_" .. image_type .. class },
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
end

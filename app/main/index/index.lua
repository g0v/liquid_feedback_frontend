slot.select("title", function()
  if app.session.member then
    execute.view{
      module = "member_image",
      view = "_show",
      params = {
        member = app.session.member,
        image_type = "avatar"
      }
    }
  end
end)

slot.select("title", function()
  ui.container{
    attr = { class = "lang_chooser" },
    content = function()
      for i, lang in ipairs{"en", "de", "eo"} do
        ui.link{
          content = function()
            ui.image{
              static = "lang/" .. lang .. ".png",
              attr = { style = "margin-left: 0.5em;", alt = lang }
            }
          end,
          text = _('Select language "#{langcode}"', { langcode = lang }),
          module = "index",
          action = "set_lang",
          params = { lang = lang },
          routing = {
            default = {
              mode = "redirect",
              module = request.get_module(),
              view = request.get_view(),
              id = param.get_id_cgi(),
              params = param.get_all_cgi()
            }
          }
        }
      end
    end
  }
end)

slot.put_into("title", encode.html(config.app_title))

if app.session.member then
  app.html_title.title = app.session.member.name
end


util.help("index.index", _"Home")

execute.view{
  module = "member",
  view = "_show",
  params = {
    member = app.session.member,
    show_as_homepage = true
  }
}

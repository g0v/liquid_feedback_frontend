-- this file is used for the drop-down language menu and for the language menu page

ui.tag{ tag = "ul", content = function()

  for i, lang in ipairs(config.enabled_languages) do

    local langcode

    locale.do_with({ lang = lang }, function()
      langcode = _("[Name of Language]")
    end)

    ui.tag{ tag = "li", content = function()
      ui.link{
        content = langcode,
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
    end }

  end

end }

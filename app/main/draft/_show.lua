local draft = param.get("draft", "table")

ui.form{
  attr = { class = "vertical" },
  record = draft,
  readonly = true,
  content = function()

    if app.session.member_id or config.public_access == "pseudonym" then
      if draft.author then
        -- ugly workaround for getting html into a replaced string und to the user
        ui.container{label = _"Last author", label_attr={class="ui_field_label"}, content = function()
            local str = _("#{author} at #{date}",
                            {author = string.format('<a href="%s">%s</a>',
                                                    encode.url{
                                                      module    = "member",
                                                      view      = "show",
                                                      id        = draft.author.id,
                                                    },
                                                    encode.html(draft.author.name)),
                             date = encode.html(format.timestamp(draft.created))
                            }
                        )
            slot.put("<span>", str, "</span>")
          end
        }
      else
        text = _("#{author} at #{date}", {
          author = encode.html(draft.author_name),
          date = format.timestamp(draft.created)
        })
        ui.field.text{label = _"Last author", value = text }
      end
    else
      ui.field.text{
        label = _"Last author",
        value = _(
          "#{author} at #{date}", {
            author = _"[not displayed public]",
            date = format.timestamp(draft.created)
          }
        )
      }
    end

    ui.container{
      attr = { class = "draft_content wiki" },
      content = function()
        slot.put(draft:get_content("html"))
      end
    }
  end
}

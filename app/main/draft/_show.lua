local draft = param.get("draft", "table")

ui.form{
  attr = { class = "vertical" },
  record = draft,
  readonly = true,
  content = function()

    if app.session.member_id or config.public_access == "pseudonym" then
      ui.field.text{
        label = _"Last author",
        value = _(
          "#{author} at #{date}", {
            author = draft.author_name,
            date = format.timestamp(draft.created)
          }
        )
      }
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

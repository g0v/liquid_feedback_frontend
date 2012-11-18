-- display the MOTD once for each session
if config.motd and (app.session.member or config.motd_public) and app.session.motd_seen ~= config.motd then
  ui.container{
    attr = { class = "wiki motd" },
    content = function()
      slot.put(format.wiki_text(config.motd))
    end
  }
  app.session.motd_seen = config.motd
  app.session:save()
end

execute.inner()

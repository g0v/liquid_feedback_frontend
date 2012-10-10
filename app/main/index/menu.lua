ui.title(_("Member menu") .. " / " .. _("Select language"))

ui.container{
  attr = { class = "menu_list" },
  content = function()
    execute.view{
      module = "index",
      view = "_menu"
    }
  end 
}

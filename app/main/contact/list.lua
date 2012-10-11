ui.title(_"Contacts")

util.help("contact.list")

local contacts_selector = Contact:build_selector{ member_id = app.session.member_id }
contacts_selector:add_field("member.*")

local paginator_name = param.get("paginator_name")

ui.add_partial_param_names{ "member_list" }

local filter = { name = "member_list" }

filter[#filter+1] = {
  name = "newest",
  label = _"Newest",
  selector_modifier = function(selector) selector:add_order_by("activated DESC, id DESC") end
}
filter[#filter+1] = {
  name = "oldest",
  label = _"Oldest",
  selector_modifier = function(selector) selector:add_order_by("activated, id") end
}

filter[#filter+1] = {
  name = "name",
  label = _"A-Z",
  selector_modifier = function(selector) selector:add_order_by("name") end
}
filter[#filter+1] = {
  name = "name_desc",
  label = _"Z-A",
  selector_modifier = function(selector) selector:add_order_by("name DESC") end
}

local ui_filters = ui.filters

ui_filters{
  label = _"Change order",
  selector = contacts_selector,
  filter,
  content = function()
    ui.paginate{
      name = paginator_name,
      anchor = paginator_name,
      selector = contacts_selector,
      per_page = 50,
      content = function()
        ui.container{
          attr = { class = "member_list" },
          content = function()
            local contacts = contacts_selector:exec()
            if #contacts == 0 then
              ui.field.text{ value = _"You didn't save any member as contact yet." }
            else

              for i, contact in ipairs(contacts) do

                ui.container{
                  attr = { class = "contact_thumb" },
                  content = function()

                    execute.view{
                      module = "member",
                      view = "_show_thumb",
                      params = {
                        member = contact
                      }
                    }

                    ui.container{
                      attr = { class = "contact_action" },
                      content = function()

                        if contact.public then
                          ui.link{
                            attr = { class = "action" },
                            module = "contact",
                            action = "add_member",
                            id = contact.id,
                            params = { public = false },
                            routing = {
                              default = {
                                mode = "redirect",
                                module = request.get_module(),
                                view = request.get_view(),
                                id = param.get_id_cgi(),
                                params = param.get_all_cgi()
                              }
                            },
                            content = function()
                              ui.image{
                                attr = {
                                  alt   = _"Published, click to hide",
                                  title = _"Published, click to hide"
                                },
                                static = "icons/16/user_green.png"
                              }
                            end
                          }
                        else
                          ui.link{
                            attr = { class = "action" },
                            module = "contact",
                            action = "add_member",
                            id = contact.id,
                            params = { public = true },
                            routing = {
                              default = {
                                mode = "redirect",
                                module = request.get_module(),
                                view = request.get_view(),
                                id = param.get_id_cgi(),
                                params = param.get_all_cgi()
                              }
                            },
                            content = function()
                              ui.image{
                                attr = {
                                  alt   = _"Hidden, click to publish",
                                  title = _"Hidden, click to publish"
                                },
                                static = "icons/16/user_gray.png"
                              }
                            end
                          }
                        end
                        ui.link{
                          attr = { class = "action" },
                          module = "contact",
                          action = "remove_member",
                          id = contact.id,
                          routing = {
                            default = {
                              mode = "redirect",
                              module = request.get_module(),
                              view = request.get_view(),
                              id = param.get_id_cgi(),
                              params = param.get_all_cgi()
                            }
                          },
                          content = function()
                          ui.image{
                            attr = {
                              alt   = _"Remove",
                              title = _"Remove"
                            },
                            static = "icons/16/delete.png"
                          }
                          end

                        }
                      end
                    }
                  end
                }
              end
            end
          end
        }
        slot.put('<br style="clear: left;" />')
      end
    }
  end
}

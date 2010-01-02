config.absolute_base_url = "http://www.public-software-group.org/liquid_feedback_testing/"

execute.config("default")

config.formatting_engine_executeables = {
  rocketwiki= "/opt/liquid_feedback_testing/rocketwiki/rocketwiki-lqfb",
  compat = "/opt/liquid_feedback_testing/rocketwiki/rocketwiki-lqfb-compat"
}

config.fastpath_url_func = function(member_id, image_type)
  return "http://www.public-software-group.org/liquid_feedback_testing/fastpath/getpic?" .. tostring(member_id) .. "+" .. tostring(image_type)
end
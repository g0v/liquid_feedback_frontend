config.app_version = "2.beta12"

config.instance_name = request.get_config_name()

config.app_service_provider = "Snake Oil<br/>10000 Berlin<br/>Germany"

config.use_terms = "=== Terms of Use ==="

config.use_terms_checkboxes = {
  {
    name = "terms_of_use_v1",
    html = "I accept the terms of use.",
    not_accepted_error = "You have to accept the terms of use to be able to register."
  }
}

config.enabled_languages = { 'en', 'de', 'eo', 'el', 'hu' }

config.default_lang = "en"

config.delegation_warning_time = '6 months'

config.mail_subject_prefix = "[LiquidFeedback] "

config.fastpath_url_func = nil

config.download_dir = nil

config.download_use_terms = "=== Nutzungsbedingungen ===\nAlles ist verboten"

config.public_access = false

config.member_image_content_type = "image/jpeg"

config.member_image_convert_func = {
  avatar = function(data) return extos.pfilter(data, "convert", "jpeg:-", "-thumbnail",   "48x48", "jpeg:-") end,
  photo =  function(data) return extos.pfilter(data, "convert", "jpeg:-", "-thumbnail", "240x240", "jpeg:-") end
}


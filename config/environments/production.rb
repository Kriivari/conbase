Conbase::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true
  config.action_controller.perform_caching = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local = false

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Compress assets
  config.assets.compress = true
  config.assets.logger = false

  config.assets.js_compressor = :uglifier

  config.time_zone = "Europe/Helsinki"

  config.secret_token = "Conasdf astebniyawzxczl4597sfxchhhhhhadshhhhhh"

  config.action_mailer.delivery_method = :sendmail

  #config.mailing_list_client = "sudo -H -u alias /usr/local/conbase/bin/enemies_of_carlotta"
  config.mailing_list_client = "/srv/conbase/conbase/bin/enemies_of_carlotta"
  #config.mailing_list_client = "/usr/local/conbase/bin/enemies_of_carlotta"
end

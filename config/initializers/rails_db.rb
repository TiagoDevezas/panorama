RailsDb.setup do |config|
  # # enabled or not
  # config.enabled = Rails.env.to_s == 'development'

  # set tables which you want to hide ONLY
  # config.black_list_tables = ['users', 'accounts']

  # set tables which you want to show ONLY
  # config.white_list_tables = ['posts', 'comments']

  # # Enable http basic authentication
  config.http_basic_authentication_enabled = true

  # # Enable http basic authentication
  config.http_basic_authentication_user_name = 'infolab'

  # # Enable http basic authentication
  config.http_basic_authentication_password = 'panorama'
end
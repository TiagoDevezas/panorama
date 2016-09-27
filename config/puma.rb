threads 2, 10
workers 1

rails_env = ENV['RAILS_ENV'] || "development"
environment rails_env

bind 'unix:///home/tiagodevezas/Projects/Panorama/tmp/panorama.sock'
pidfile "/home/tiagodevezas/Projects/Panorama/tmp/puma/puma.pid"
state_path "/home/tiagodevezas/Projects/Panorama/tmp/puma/puma.state"
activate_control_app

# on_worker_boot do
#   require "active_record"
#   ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
#   ActiveRecord::Base.establish_connection(YAML.load_file("/home/tiagodevezas/Projects/Panorama/config/database.yml")[rails_env])
# end

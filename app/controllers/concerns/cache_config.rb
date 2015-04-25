module CacheConfig
	extend ActiveSupport::Concern

	# def fetch_or_create_cache(key_params, time_to_expire, collection)
	# 	Rails.cache.fetch(key_params, expires_in: time_to_expire) do
	# 		collection.to_a.each do |col|
	# 			col
	# 		end
	# 	end
	# end

	def self.included(base)
    base.caches_action :index, cache_path: Proc.new {|c| c.params.except(:callback) }, expires_in: 1.hour
  end

end
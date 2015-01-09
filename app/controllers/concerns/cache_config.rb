module CacheConfig
	extend ActiveSupport::Concern

	def self.included(base)
    base.caches_action :index, cache_path: Proc.new {|c| c.params.except(:callback) }, expires_in: 15.minutes
  end

end
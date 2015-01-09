module Api
	class FeedsController < ApplicationController
		include CacheConfig
		respond_to :json

		def index

			source_params = params[:source]

			if source_params
				source = Source.where(name: source_params).empty? ? Source.where(acronym: source_params) : Source.where(name: source_params)
				@feeds = source.first.feeds
			else 
				@feeds = Feed.all
			end
		end

	end

end
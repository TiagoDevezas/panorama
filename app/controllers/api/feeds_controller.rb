module Api
	class FeedsController < ApplicationController
		respond_to :json

		def index
			@feeds = Feed.all

			source_params = params[:source]

			if source_params
				source = Source.where(name: source_params).first
				@feeds = source.feeds
			end
		end

	end

end
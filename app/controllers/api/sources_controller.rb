module Api
	class SourcesController < ApplicationController
		respond_to :json

		def index
			name_params = params[:name]

			type_params = params[:type]

			query_params = params[:q]


			if name_params
				@sources = Source.where(name: name_params)
			end

			if type_params
				@sources = Source.where(source_type: type_params)
			end

		end

	end

end
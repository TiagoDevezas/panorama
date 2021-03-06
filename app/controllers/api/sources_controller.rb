module Api
	class SourcesController < ApplicationController
		include CacheConfig
		respond_to :json

		def index
			name_params = params[:name]
			type_params = params[:type]

			if !name_params && !type_params
				@sources_list = Source.order(source_type: :desc, name: :asc).map { |source| { name: source.name, acronym: source.acronym, type: source.source_type }}
				#all_source_data = Source.all_sources_data
				#@sources_list = all_source_data[0][:sources]
			end

			if name_params != 'All'
				@sources = Source.where(name: name_params).empty? ? Source.where(acronym: name_params) : Source.where(name: name_params) 
			end

			if type_params
				@sources = Source.where(source_type: type_params)
			end

		end

	end

end
class SourcesController < ApplicationController

	def index
		@national = Source.where(source_type: 'national') #.joins(:articles).includes(:articles).order('pub_date desc')
		@blogs = Source.where(source_type: 'blogs') #.joins(:articles).includes(:articles).order('pub_date desc')
		@international = Source.where(source_type: 'international') #.joins(:articles).includes(:articles).order('pub_date desc')
	end

	def new
		@source = Source.new
		@source.feeds.build
	end

	def create
		@source = Source.new(source_params)

		if @source.save
			redirect_to sources_path
		else
			render 'new'
		end

	end

	def show
		@source = Source.find(params[:id])
	end

	def edit
		@source = Source.find(params[:id])
	end

	def update
		@source = Source.find(params[:id])

		if @source.update(source_params)
			redirect_to sources_path
		else
			render 'edit'
		end
	end

	def destroy
		@source = Source.find(params[:id])
		@source.destroy

		redirect_to sources_path
	end

	private
		def source_params
			params.require(:source).permit(:name, :acronym, :url, :source_type, feeds_attributes: [:id, :name, :url, :source_id, :_destroy])
		end

end

class DashboardController < ApplicationController
	def index
		@sources = Source.all
	end
end

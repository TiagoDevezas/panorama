module Api
	class TotalsController < ApplicationController
		include CheckApiTimeConstraints
		respond_to :json

		def index

			source = params[:source]
			by = params[:by]
			query = params[:q]
			
			@days_and_totals = []

			if source
				source = Source.find_by(name: source)
				@articles = source.articles
				check_time_constraints
				if query
					@articles = @articles.find_articles_with(query)
				end
				@days_and_totals = @articles.get_count_by('day')
				if by && by == 'month'
					@days_and_totals = @articles.get_count_by('month')
				elsif by && by == 'hour'
					@days_and_totals = @articles.get_count_by('hour')
				end
			else
				if query
					@articles = Article.find_articles_with(query)
				else
					@articles = Article.all
				end
				check_time_constraints
				@days_and_totals = @articles.get_count_by('day')
				if by && by == 'month'
					@days_and_totals = @articles.get_count_by('month')
				elsif by && by == 'hour'
					@days_and_totals = @articles.get_count_by('hour')
				end
			end

		end

	end

end
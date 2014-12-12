module Api
	class TotalsController < ApplicationController
		include CheckApiTimeConstraints
		respond_to :json

		def index

			source = params[:source]
			by = params[:by]
			query = params[:q]
			category = params[:category]
			@type = params[:type]
			
			@days_and_totals = []

			if source
				source = Source.find_by(name: source)
				@articles = source.articles
			elsif @type
				@articles = Article.with_source_type(@type)
			else
				@articles = Article.all
			end

			if query
				@articles = @articles.find_articles_with(query)
				@get_percent = true
			end
			if category
				@articles = @articles.with_category(category)
			end
			check_time_constraints
			@days_and_totals = @articles.get_count_by('day')
			if by && by == 'month'
				@days_and_totals = @articles.get_count_by('month')
			end
			if by && by == 'hour'
				@days_and_totals = @articles.get_count_by('hour')
			end
			if by && by == 'week'
				@days_and_totals = @articles.get_count_by('week')
			end

		end

	end

end
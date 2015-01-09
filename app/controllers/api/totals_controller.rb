module Api
	class TotalsController < ApplicationController
		include CheckApiTimeConstraints
		include CacheConfig
		respond_to :json

		def index

			source = params[:source]
			by = params[:by]
			query = params[:q]
			category = params[:category]
			type = params[:type]
			
			@days_and_totals = []

			if source
				source = Source.where(name: source).empty? ? Source.where(acronym: source).first : Source.where(name: source).first
				@articles = source.articles
				@source_article_count = @articles.size
			elsif type
				@articles = Article.with_source_type(type)
				@type_article_count = @articles.size
			else
				@articles = Article.all
			end

			if query
				@articles = @articles.find_articles_with(query)
				@query_article_count = @articles.size
				if type && (!by || by == 'day') 
					@get_percent_of_source_type = true
					@articles_with_source_type = Article.with_source_type(type)
				end
			end
			if category
				@articles = @articles.with_category(category)
			end
			check_time_constraints
			if !by || by == 'day'
				@days_and_totals = @articles.get_count_by('day')
			end
			if by == 'month'
				@days_and_totals = @articles.get_count_by('month')
			end
			if by == 'hour'
				@days_and_totals = @articles.get_count_by('hour')
			end
			if by == 'week'
				@days_and_totals = @articles.get_count_by('week')
			end

		end

	end

end
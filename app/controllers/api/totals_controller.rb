module Api
	class TotalsController < ApplicationController
		include CheckApiTimeConstraints
		respond_to :json

		def index

			source = params[:source]
			by = params[:by]
			query = params[:q]
			category = params[:category]
			type = params[:type]
			
			@days_and_totals = []

			if source
				source = Source.find_by(name: source)
				@articles = source.articles
				if query
					@articles = @articles.find_articles_with(query)
				end
				if category
					@articles = @articles.with_category(category)
				end
				check_time_constraints
				@days_and_totals = @articles.get_count_by('day')
				if by && by == 'month'
					@days_and_totals = @articles.get_count_by('month')
				elsif by && by == 'hour'
					@days_and_totals = @articles.get_count_by('hour')
				end
			# elsif type
			# 	sources = Source.where(source_type: type)
			# 	@articles =	sources.each.map { |s| s.articles }
			# 	if query
			# 		@articles = @articles.find_articles_with(query)
			# 	end
			# 	if category
			# 		@articles = @articles.with_category(category)
			# 	end
			# 	check_time_constraints
			# 	@days_and_totals = @articles.get_count_by('day')
			# 	if by && by == 'month'
			# 		@days_and_totals = @articles.get_count_by('month')
			# 	elsif by && by == 'hour'
			# 		@days_and_totals = @articles.get_count_by('hour')
			# 	end
			else
				@articles = Article.all
				if query
					@articles = Article.find_articles_with(query)
				end
				if category
					@articles = @articles.with_category(category)
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
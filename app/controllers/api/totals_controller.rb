module Api
	class TotalsController < ApplicationController
		include CheckApiTimeConstraints
		include CacheConfig
		respond_to :json

		def index

			source = params[:source]
			by = params[:by]
			query = params[:q]
			fields = params[:fields]
			category = params[:category]
			type = params[:type]
			
			@days_and_totals = []

			if query
				if !fields
					@articles = Article.find_articles_with(query)
				elsif fields == 'title'
					@articles = Article.find_in_title(query)
				elsif fields  == 'summary'
					@articles = Article.find_in_summary(query)
				end
				@query_article_count = @articles.length
				if type
					@articles = @articles.with_source_type(type)
					@type_article_count = Article.with_source_type(type).size
					if type && (!by || by == 'day') 
						@get_percent_of_source_type = true if !@articles.empty?
					end
				end

				if source
					source = Source.where(name: source).empty? ? Source.where(acronym: source).first : Source.where(name: source).first
					@articles = @articles.joins(:feed => :source).where('sources.name LIKE ? OR sources.acronym LIKE ?', "#{source.name}", "#{source.acronym}")
					@source_article_count = source.articles.length
				end
			else
				if source
					source = Source.where(name: source).empty? ? Source.where(acronym: source).first : Source.where(name: source).first
					@articles = source.articles
					@source_article_count = @articles.length
				elsif type
					@articles = Article.with_source_type(type)
					@type_article_count = @articles.length
				else
					@articles = Article.all
				end
			end

			if category
				@articles = @articles.with_category(category)
			end
			check_time_constraints
			if !by || by == 'day'
				@days_and_totals = @articles.get_count_by('day')
				if @get_percent_of_source_type 
					first_date = @days_and_totals.first[:time]
					last_date = @days_and_totals.last[:time]
					@source_type_totals = Article.with_source_type(type).reorder('').where("to_char(pub_date, 'YYYY-MM-DD') BETWEEN ? AND ?", first_date, last_date).get_count_by('day')
				end
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
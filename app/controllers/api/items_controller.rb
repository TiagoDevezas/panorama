module Api
	class ItemsController < ApplicationController
		include CheckApiTimeConstraints
		include CacheConfig
		respond_to :json

		def index

			limit = params[:limit]
			source = params[:source]
			offset = params[:offset]
			query = params[:q]
			fields = params[:fields]
			category = params[:category]
			type = params[:type]

			sort = params[:sort]

			if limit.to_i == -1
				limit = nil
			elsif limit.to_i >= 1
				limit = limit
			else
				limit = 10
			end

			if !source
				@articles = Article.limit(limit).offset(offset).where('pub_date IS NOT NULL')
			end
			
			if source
				source = Source.where(name: source).empty? ? Source.where(acronym: source) : Source.where(name: source)
				@articles = source.first.articles.limit(limit).offset(offset).where('pub_date IS NOT NULL')
			end

			if type
				@articles = Article.with_source_type(type).limit(limit).offset(offset).where('pub_date IS NOT NULL')
			end

			if query
				if !fields
					@articles = @articles.find_articles_with(query).limit(limit)
				elsif fields == 'title'
					@articles = @articles.find_in_title(query).limit(limit)
				elsif fields  == 'summary'
					@articles = @articles.find_in_summary(query).limit(limit)
				end
			end
			if category
				@articles = @articles.with_category(category).limit(limit)
			end

			# if source
			# 	@articles = Source.find_by(name: source).articles.limit(limit).offset(offset).where('pub_date IS NOT NULL')
			# 	if query
			# 		@articles = @articles.find_articles_with(query).limit(limit)
			# 	end
			# 	if category
			# 		@articles = @articles.with_category(category).limit(limit)
			# 	end
			# else
			# 	@articles = Article.limit(limit).offset(offset).where('pub_date IS NOT NULL')
			# 	if query
			# 		@articles = @articles.find_articles_with(query).limit(limit)
			# 	end
			# 	if category
			# 		@articles = @articles.with_category(category).limit(limit)
			# 	end
			# end
			if sort && sort == 'asc'
				@sort_ascending = true
			end

			@articles = check_time_constraints(@articles)

			# fetch_or_create_cache(params.except(:callback), 10.minutes, @articles)

		end

	end

end
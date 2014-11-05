module Api
	class ItemsController < ApplicationController
		include CheckApiTimeConstraints
		respond_to :json

		def index

			limit = params[:limit]
			source = params[:source]
			offset = params[:offset]
			query = params[:q]

			if limit == 'off'
				limit = nil
			elsif limit.to_i >= 1
				limit = limit
			else
				limit = 10
			end

			if source
				@articles = Source.find_by(name: source).articles.limit(limit).offset(offset).where('pub_date IS NOT NULL')
				if query
					@articles = @articles.find_articles_with(query)
				end
			else
				@articles = Article.limit(limit).offset(offset).where('pub_date IS NOT NULL')
				if query
					@articles = @articles.find_articles_with(query)
				end
			end

			check_time_constraints

		end

	end

end
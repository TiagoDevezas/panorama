module CheckApiTimeConstraints
	extend ActiveSupport::Concern

	def check_time_constraints
		start_date = params[:since]
		end_date = params[:until]

		if start_date
			articles_pub_date = @articles.where('pub_date >= ?', start_date.to_datetime)
			# Workaround for P3 articles without publishing date. We use the updated_at date instead of the inexisting pub_date
			#articles_no_pub_date = @articles.where(pub_date: nil).where('articles.created_at >= ?', start_date.to_datetime)
			#all_articles = articles_pub_date + articles_no_pub_date
			#@articles = Article.where(id: all_articles.map(&:id))
			@articles = articles_pub_date
		end

		if end_date
			articles_pub_date = @articles.where('pub_date <= ?', end_date.to_datetime + 1.day)
			#articles_no_pub_date = @articles.where(pub_date: nil).where('articles.created_at <= ?', end_date.to_datetime + 1.day)
			#all_articles = articles_pub_date + articles_no_pub_date
			#@articles = Article.where(id: all_articles.map(&:id))
			@articles = articles_pub_date
		end

		if start_date && end_date
			articles_pub_date = @articles.where(
				'pub_date BETWEEN ? AND ?', start_date.to_datetime, end_date.to_datetime + 1.day
			)
			#articles_no_pub_date = @articles.where(pub_date: nil).where('articles.created_at BETWEEN ? AND ?', start_date.to_datetime, end_date.to_datetime)
			#all_articles = articles_pub_date + articles_no_pub_date
			#@articles = Article.where(id: all_articles.map(&:id))
			@articles = articles_pub_date
		end
	end
end
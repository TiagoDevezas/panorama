module CheckApiTimeConstraints
	extend ActiveSupport::Concern

	def check_time_constraints(articles)
		start_date = params[:since]
		end_date = params[:until]

		if start_date && !end_date
			articles_pub_date = articles.where('pub_date >= ?', start_date.to_datetime)
		end

		if end_date && !start_date
			articles_pub_date = articles.where('pub_date <= ?', end_date.to_datetime + 1.day)
		end

		if start_date && end_date
			articles_pub_date = articles.where(
				'pub_date BETWEEN ? AND ?', start_date.to_datetime, end_date.to_datetime + 1.day
			)
		end

		if !start_date && !end_date
			articles_pub_date = articles
		end

		articles_pub_date
	end
end
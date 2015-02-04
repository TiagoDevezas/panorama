if @days_and_totals

	json.array! @days_and_totals do |el|
		json.time el[:time]
		json.articles el[:count]
		if @source_article_count
			json.total_source_articles @source_article_count
			json.percent_of_source ((el[:count] / @source_article_count.to_f) * 100).round(2)
		end
		if @type_article_count
			json.total_type_articles @type_article_count
			json.percent_of_type ((el[:count] / @type_article_count.to_f) * 100).round(2)
		end
		if @query_article_count
			json.total_query_articles @query_article_count
			json.percent_of_query ((el[:count] / @query_article_count.to_f) * 100).round(2)
		end
		if @get_percent_of_source_type
			articles_with_source_type_length = @source_type_totals.select { |h| h[:time].to_s == el[:time] }.first[:count]
			json.total_articles_of_type_by_day articles_with_source_type_length
			json.percent_of_type_by_day ((el[:count] / articles_with_source_type_length.to_f) * 100 ).round(2)
		end
		json.twitter_shares el[:twitter_shares]
		json.facebook_shares el[:facebook_shares]
		json.total_shares el[:total_shares]
	end
	
end




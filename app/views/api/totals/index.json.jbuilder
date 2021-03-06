days_and_totals_for_type = @days_and_totals_for_type
days_and_totals_for_source = @days_and_totals_for_source
total_period_twitter_shares = @days_and_totals.map { |h| h[:twitter_shares]}.sum
total_period_facebook_shares = @days_and_totals.map { |h| h[:facebook_shares]}.sum
total_period_shares = total_period_twitter_shares + total_period_facebook_shares

if @days_and_totals

	json.array! @days_and_totals do |el|
		json.time el[:time]
		json.articles el[:count]
		if @source_article_count
			if days_and_totals_for_source
				articles_for_day = days_and_totals_for_source.select { |obj| obj[:time] == el[:time]}[0][:count]
				json.total_articles_for_day articles_for_day
				json.percent_of_day ((el[:count] / articles_for_day.to_f) * 100).round(2)
			end
			json.total_source_articles @source_article_count
			json.percent_of_source ((el[:count] / @source_article_count.to_f) * 100).round(2) || 0
		end
		if @type_article_count
			if days_and_totals_for_type
				type_article_count = days_and_totals_for_type.map { |h| h[:count] }.sum
				articles_for_day = days_and_totals_for_type.select { |obj| obj[:time] == el[:time]}[0][:count]
				json.total_articles_for_day articles_for_day
				json.total_type_articles type_article_count
				json.percent_of_type_by_day ((el[:count] / articles_for_day.to_f) * 100 ).round(2)
			end
			if !days_and_totals_for_type
				type_article_count = @type_article_count
			end
			#type_article_count = days_and_totals_for_type.map { |h| h[:count] }.sum
			#articles_for_day = days_and_totals_for_type.select { |obj| obj[:time] == el[:time]}[0][:count]
			#json.total_articles_for_day articles_for_day
			#json.total_type_articles @type_article_count
			json.total_type_articles type_article_count
			json.percent_of_type ((el[:count] / type_article_count.to_f) * 100).round(2)
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
		if @time_period_count
			json.total_period_articles @time_period_count
		end
		json.twitter_shares el[:twitter_shares]
		json.twitter_shares_percent ((el[:twitter_shares] / total_period_twitter_shares.to_f) * 100).round(2)
		json.facebook_shares el[:facebook_shares]
		json.facebook_shares_percent ((el[:facebook_shares] / total_period_facebook_shares.to_f) * 100).round(2)
		json.total_shares el[:total_shares]
		json.total_shares_percent ((el[:total_shares] / total_period_shares.to_f) * 100).round(2)
	end
	
end




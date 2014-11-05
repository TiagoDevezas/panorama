json.array! @days_and_totals do |el|
	json.time el[:time]
	json.articles el[:count]
	json.twitter_shares el[:twitter_shares]
	json.facebook_shares el[:facebook_shares]
	json.total_shares el[:total_shares]
end


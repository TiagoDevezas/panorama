json.array! @stats do |stat|
	json.sources_count stat[:sources_count]
	json.feeds_count stat[:feeds_count]
	json.articles_count stat[:articles_count]
	json.articles_day stat[:articles_day]
	json.articles_hour stat[:articles_hour]
	json.twitter_shares stat[:twitter_shares]
	json.facebook_shares stat[:facebook_shares]
	json.shares_count stat[:shares_count]
end



json.array! @feeds do |feed|
	article_count = feed.articles.count
	twitter_shares = feed.articles.map(&:twitter_shares).compact.sum
	avg_twitter_shares = (twitter_shares / article_count.to_f).round(2)
	facebook_shares = feed.articles.map(&:facebook_shares).compact.sum
	avg_facebook_shares = (facebook_shares / article_count.to_f).round(2)

	json.id feed.id
	json.name feed.name
	json.url feed.url
	json.source_id feed.source_id
	json.source feed.source.name
	json.total_items article_count
	json.twitter_shares twitter_shares
	#json.avg_twitter_shares avg_twitter_shares
	json.facebook_shares facebook_shares
	#json.avg_facebook_shares avg_facebook_shares
end
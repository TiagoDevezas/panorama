json.array! @articles do |article|
	twitter_shares = article.twitter_shares
	facebook_shares = article.facebook_shares
	total_shares = twitter_shares + facebook_shares

	json.id article.id
	json.title article.title
	json.url article.url
	json.summary article.summary
	json.twitter_shares twitter_shares
	json.facebook_shares facebook_shares
	json.total_shares total_shares
	json.pub_date article.pub_date
	json.feed_id article.feed_id
	json.feed article.feed.name
	json.source article.feed.source.name
	json.categories article.cats, :name
end
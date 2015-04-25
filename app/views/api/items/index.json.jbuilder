if @sort_ascending
	@articles =  @articles.reorder('pub_date ASC').includes(:cats).includes(:feed => :source)
else
	@articles = @articles.includes(:cats).includes(:feed => :source)
end
json.array! @articles do |article|

	parsed_summary = Nokogiri::HTML.parse(article.summary)
	parsed_summary.search('p').each { |p| p.after "\n" }
	clean_summary = parsed_summary.text.strip

	twitter_shares = article.twitter_shares.to_i
	facebook_shares = article.facebook_shares.to_i
	total_shares = twitter_shares + facebook_shares

	json.id article.id
	json.title article.title
	json.url article.url
	json.summary simple_format(clean_summary)
	json.twitter_shares twitter_shares
	json.facebook_shares facebook_shares
	json.total_shares total_shares
	json.pub_date article.pub_date
	json.feed_id article.feed_id
	json.feed article.feed.name
	json.source article.feed.source.name
	json.source_type article.feed.source.source_type
	json.categories article.cats, :name
end
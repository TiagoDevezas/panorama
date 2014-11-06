if @sources
	json.array! @sources do |source|
		article_count = source.articles.count
		twitter_shares = source.articles.map(&:twitter_shares).sum
		avg_twitter_shares = (twitter_shares / article_count.to_f).round(2)
		facebook_shares = source.articles.map(&:facebook_shares).sum
		avg_facebook_shares = (facebook_shares / article_count.to_f).round(2)
		total_shares = twitter_shares + facebook_shares
		avg_shares = (total_shares / article_count.to_f).round(2) 

		json.id source.id
		json.name source.name
		json.type source.source_type
		json.total_feeds source.feeds.count
		json.total_items article_count
		json.total_shares total_shares 
		json.twitter_shares twitter_shares
		json.avg_twitter_shares avg_twitter_shares
		json.facebook_shares facebook_shares
		json.avg_facebook_shares avg_facebook_shares
		json.avg_shares avg_shares
		json.avg_day source.articles.average_articles_by('day')
		json.avg_month source.articles.average_articles_by('month')
		json.categories source.articles.category_list.each do |category|
			json.name category[0].strip
			json.count category[1]
		end
	end
else
	source = Source.all_sources_data
		json.name source[:name]
		json.total_feeds source[:total_feeds]
		json.total_items source[:total_items]
		json.total_shares source[:total_shares ]
		json.twitter_shares source[:twitter_shares]
		json.avg_twitter_shares source[:avg_twitter_shares]
		json.facebook_shares source[:facebook_shares]
		json.avg_facebook_shares source[:avg_facebook_shares]
		json.avg_shares source[:avg_shares]
		json.avg_day source[:avg_day]
		json.avg_month source[:avg_month]
		json.categories source[:categories].each do |category|
			json.name category[0]
			json.count category[1]
		end
end
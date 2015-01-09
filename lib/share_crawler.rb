class ShareCrawler

	def get_social_shares
		article = Article.where('pub_date < ?', 1.week.ago)
																				 .where(twitter_shares: nil)
																				 .where(facebook_shares: nil).last
		if article
	  	twitter_url = "https://cdn.api.twitter.com/1/urls/count.json?url="
	  	facebook_url = "https://api.facebook.com/method/links.getStats?format=json&urls="
	  	article_url = ERB::Util.url_encode(article.url)
	  	twitter_response = open(twitter_url + article_url).read
	  	twitter_shares = JSON.parse(twitter_response)['count']
	  	facebook_response = open(facebook_url + article_url).read
	  	facebook_shares = JSON.parse(facebook_response)[0]['share_count']
	  	shares = Hash['twitter' => twitter_shares, 'facebook' => facebook_shares]
	  	article.update(twitter_shares: shares['twitter'], facebook_shares: shares['facebook'])
	  # 	if article.twitter_shares != shares['twitter']
	  # 		article.update(twitter_shares: shares['twitter'])
	  # 		#puts "Twitter shares changed"
	  # 	end
	  # 	if article.facebook_shares != shares['facebook']
	  # 		article.update(facebook_shares: shares['facebook'])
	  # 		#puts "Facebook shares changed"
			# end
		else
			puts "Error"
		end
	end
end
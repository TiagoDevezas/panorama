class ShareCrawler

	def get_social_shares(network)
		if network == 'twitter'
			get_twitter_shares
		elsif network == 'facebook'
			get_facebook_shares
		elsif network == 'all'
			get_twitter_shares
			get_facebook_shares
		end
	end

	def get_twitter_shares
		# safely do
			Rails.logger.debug "A actualizar partilhas no Twitter..."
			article = Article.reorder('pub_date asc')
												.where('pub_date < ?', 1.week.ago)
											 	.where(twitter_shares: nil).first
			if article
				http_client = HTTPClient.new
				twitter_url = "https://cdn.api.twitter.com/1/urls/count.json?url="
		  	article_url = ERB::Util.url_encode(article.url.strip)
		  	twitter_response = http_client.get(twitter_url + article_url)
		  	twitter_shares = JSON.parse(twitter_response.body)['count']
		  	shares = Hash['twitter' => twitter_shares] || 0
		  	article.update(twitter_shares: shares['twitter'])
			else
				Rails.logger.error "[ERROR] getting Twitter shares"
			end
		# end
	end

	def get_facebook_shares
		# safely do
			Rails.logger.debug "A actualizar partilhas no Facebook..."
			article = Article.reorder('pub_date asc')
												.where('pub_date < ?', 1.week.ago)
											 	.where(facebook_shares: nil).first
			if article
				http_client = HTTPClient.new
				facebook_url = "https://api.facebook.com/method/links.getStats?format=json&urls="
		  	article_url = ERB::Util.url_encode(article.url)
		  	url = "#{facebook_url}\"#{article_url}\""
		  	facebook_response = http_client.get(url)
		  	facebook_shares = JSON.parse(facebook_response.body)[0]['share_count']
		  	shares = Hash['facebook' => facebook_shares] || 0
		  	article.update(facebook_shares: shares['facebook'])
			else
				Rails.logger.error "[ERROR] getting Facebook shares"
			end
		# end
	end

	# def safely
	# 	ActiveRecord::Base.connection_pool.with_connection do |conn|
	# 		ActiveRecord::Base.connection_pool.reap
	#     yield
	#     ActiveRecord::Base.connection_pool.remove(conn)
	#   end
	# end

end
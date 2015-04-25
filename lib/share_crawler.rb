require 'httpclient'
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
		Rails.logger.debug "A actualizar partilhas no Twitter..."
		article = Article.where('pub_date < ?', 1.week.ago)
										 .where(twitter_shares: nil).last
		if article
			http_client = HTTPClient.new
			twitter_url = "https://cdn.api.twitter.com/1/urls/count.json?url="
	  	article_url = ERB::Util.url_encode(article.url.strip)
	  	twitter_response = http_client.get(twitter_url + article_url)
	  	twitter_shares = JSON.parse(twitter_response.body)['count']
	  	shares = Hash['twitter' => twitter_shares]
	  	article.update(twitter_shares: shares['twitter'])
		else
			Rails.logger.error "[ERROR] getting Twitter shares"
		end
	end

	def get_facebook_shares
		Rails.logger.debug "A actualizar partilhas no Facebook..."
		article = Article.where('pub_date < ?', 1.week.ago)
										 .where(facebook_shares: nil).last
		if article
			http_client = HTTPClient.new
			facebook_url = "https://api.facebook.com/method/links.getStats?format=json&urls="
	  	article_url = ERB::Util.url_encode(article.url)
	  	url = "#{facebook_url}\"#{article_url}\""
	  	facebook_response = http_client.get(url)
	  	facebook_shares = JSON.parse(facebook_response.body)[0]['share_count']
	  	shares = Hash['facebook' => facebook_shares]
	  	article.update(facebook_shares: shares['facebook'])
		else
			Rails.logger.error "[ERROR] getting Facebook shares"
		end
	end

end
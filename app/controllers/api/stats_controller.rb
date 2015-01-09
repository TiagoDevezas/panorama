module Api
	class StatsController < ApplicationController
		include CacheConfig
		respond_to :json

		def index
			first_article = Article.where('pub_date IS NOT NULL').last
			last_article = Article.where('pub_date IS NOT NULL').first
			day_count = (last_article.pub_date - first_article.pub_date).to_i / 1.day
			hour_count = (last_article.pub_date - first_article.pub_date).to_i / 1.hour
			sources_count = Source.all.size
			feeds_count = Feed.all.size
			articles_count = Article.all.size
			all_articles = Article.all
			twitter_shares = all_articles.map(&:twitter_shares).compact.sum
			facebook_shares = all_articles.map(&:facebook_shares).compact.sum
			all_shares = twitter_shares + facebook_shares

			@stats = []

			@stats << Hash[
				sources_count: sources_count,
				feeds_count: feeds_count,
				articles_count: articles_count,
				articles_day: (articles_count / day_count),
				articles_hour: (articles_count / hour_count),
				twitter_shares: twitter_shares,
				facebook_shares: facebook_shares,
				shares_count: all_shares
			]
		end

	end

end
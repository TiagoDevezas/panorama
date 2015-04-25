class Source < ActiveRecord::Base
	#after_save :fetch_articles

	has_many :feeds, dependent: :destroy
	has_many :articles, through: :feeds
	accepts_nested_attributes_for :feeds, allow_destroy: true
	validates :name, :url, presence: true, uniqueness: true
	validates :acronym, uniqueness: true
	validates :source_type, presence: true 

	# def get_unique_days
	# 	self.articles.pluck(:pub_date).map { |date|
	# 			date.strftime('%Y-%m-%d')
	# 	}.uniq.sort
	# end

	# def get_article_count_by(time_period)
	# 	time_and_totals = []
	# 	if time_period == 'day'
	# 		days = self.get_unique_days
	# 		days.each do |day|
	# 			count = self.articles.where("pub_date BETWEEN ? AND ?", 
	# 				day.to_datetime, day.to_datetime + 1).count
	# 			time_and_totals << [day, count]
	# 		end
	# 	end
	# 	if time_period == 'month'
	# 		(1..12).to_a.each do |month|
	# 			count = self.articles.where("extract(month from pub_date) = ?", month).count
	# 			time_and_totals << [month, count]
	# 		end
	# 	end
	# 	if time_period == 'hour'
	# 		(0..23).to_a.each do |hour|
	# 			count = self.articles.where("extract(hour from pub_date) = ?", hour).count
	# 			time_and_totals << [hour, count]
	# 		end
	# 	end
	# 	time_and_totals
	# end

	def self.all_sources_data
		total_feeds = Feed.count
		articles = Article.all
		total_items = articles.count
		twitter_shares = articles.map(&:twitter_shares).sum
		facebook_shares = articles.map(&:facebook_shares).sum
		total_shares = twitter_shares + facebook_shares
		#total_shares = articles.get_count_by('day').map { |h| h[:total_shares]}.sum
		#twitter_shares = articles.get_count_by('day').map { |h| h[:twitter_shares]}.sum
		avg_twitter_shares = (twitter_shares / total_items.to_f).round(2)
		#facebook_shares = articles.get_count_by('day').map { |h| h[:facebook_shares]}.sum
		avg_facebook_shares = (facebook_shares / total_items.to_f).round(2)
		avg_shares = (total_shares / total_items.to_f).round(2)
		avg_day = articles.average_articles_by('day')
		avg_month = articles.average_articles_by('month')
		sources = Source.all
		categories = articles.category_list
		data = Hash[
						name: 'All',
						total_feeds: total_feeds,
						total_items: total_items,
						total_shares: total_shares,
						twitter_shares: twitter_shares,
						avg_twitter_shares: avg_twitter_shares,
						facebook_shares: facebook_shares,
						avg_facebook_shares: avg_facebook_shares,
						avg_shares: avg_shares,
						avg_day: avg_day,
						avg_month: avg_month,
						sources: sources,
						categories: categories	
					]
		data_array = []
		data_array << data
	end

end

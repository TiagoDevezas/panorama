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

	# def average_articles_by(time_period)
	# 	articles = self.articles
	# 	article_count = articles.count
	# 	first_date = articles.first.pub_date ? articles.first.pub_date : articles.first.updated_at
	# 	last_date = articles.last.pub_date ? articles.last.pub_date : articles.last.updated_at
	# 	if time_period == 'day'
	# 		num_days = (first_date.to_date - last_date.to_date)
	# 		avg_per_day = num_days > 0 ? (article_count / num_days).to_f.round(2) : article_count
	# 	elsif time_period == 'month'
	# 		num_months = (first_date.year * 12 + first_date.month) - (last_date.year * 12 + last_date.month).to_i
	# 		avg_per_month = num_months > 0 ? article_count / num_months : 0
	# 	end		
	# end

  # def get_share_count(url)
  # 	twitter_url = "https://cdn.api.twitter.com/1/urls/count.json?url="
  # 	facebook_url = "https://api.facebook.com/method/links.getStats?format=json&urls="
  # 	article_url = ERB::Util.url_encode(url)
  # 	twitter_response = open(twitter_url + article_url).read
  # 	twitter_shares = JSON.parse(twitter_response).count
  # 	facebook_response = open(facebook_url + article_url).read
  # 	facebook_shares = JSON.parse(facebook_response)[0]['share_count']
  # 	shares = Hash['twitter' => twitter_shares, 'facebook' => facebook_shares]
  # end

  # def self.get_share_count(url)
  # 	twitter_url = "https://cdn.api.twitter.com/1/urls/count.json?url="
  # 	facebook_url = "https://api.facebook.com/method/links.getStats?format=json&urls="
  # 	article_url = ERB::Util.url_encode(url)
  # 	twitter_response = open(twitter_url + article_url).read
  # 	twitter_shares = JSON.parse(twitter_response).count
  # 	facebook_response = open(facebook_url + article_url).read
  # 	facebook_shares = JSON.parse(facebook_response)[0]['share_count']
  # 	shares = Hash['twitter' => twitter_shares, 'facebook' => facebook_shares]
  # end
	
	# private

	# def self.resolve_url(entry_url)
	# 	url = Addressable::URI.parse(entry_url)
	# 	http_client = HTTPClient.new
	# 	max_redirects = 2
	# 	begin
	# 		resp = http_client.get(url)
	# 		resolved_url = resp.header['Location']
	# 		if resolved_url.length > 0
	# 			while max_redirects != 0
	# 				new_location = http_client.get(resolved_url[0]).header['Location']
	# 				break if new_location.length == 0
	# 				resolved_url = new_location
	# 				max_redirects -= 1
	# 			end
	# 			resolved_url[0]
	# 		else
	# 			entry_url
	# 		end
	# 	rescue => e
	# 		puts "Can't resolve URL, Error #{e}"
	# 		entry_url
	# 	end
	# end

	# # Ugly hack to save feeds incorrectly identified as iTunes RSS
	# classes_without_itunes = Feedjira::Feed.feed_classes.reject { |klass| klass == Feedjira::Parser::ITunesRSS }
	# Feedjira::Feed.instance_variable_set(:'@feed_classes', classes_without_itunes)

	# 	def fetch_articles
	# 		self.feeds.each do |feed|
	# 			parsed_feed = Feedjira::Feed.fetch_and_parse feed.url
	# 			feed_entries = parsed_feed.entries
	# 			feed.update(last_modified: last_modified_time)
	# 			feed_entries.each do |entry|
	# 				if entry.published
	# 					next if entry.published.to_date < Date.today - 3.days || entry.published.to_date > Date.tomorrow
	# 				end
	# 				resolved_url = resolve_url(entry.url)
	# 				Article.where(url: resolved_url).first_or_create do |article|
	# 					article.title = entry.title
	# 					article.url = resolved_url
	# 					article.pub_date = entry.published
	# 					article.summary = entry.summary
	# 					article.feed_id = feed.id

	# 					if entry.categories.length > 0
	# 						entry.categories.each do |category|
	# 							cat = Cat.where(name: category.downcase.strip).first_or_create
	# 							cat.articles << article
	# 						end
	# 					end

	# 					end
	# 				# a = Article.new(
	# 				# 	title: entry.title,
	# 				# 	url: resolved_url,
	# 				# 	pub_date: entry.published,
	# 				# 	summary: entry.summary,
	# 				# 	feed_id: feed.id
	# 				# )
	# 				# if a.save
	# 				# 	entry.categories.each do |category|
	# 				# 		cat = Cat.where(name: category.downcase.strip).first_or_create
	# 				# 		cat.articles << a
	# 				# 	end
	# 				# end	
	# 			end
	# 		end
	# 	end

	# 	def self.update_feeds
	# 		self.all.each do |source|
	# 			source.feeds.each do |feed|
	# 				parsed_feed = Feedjira::Feed.fetch_and_parse feed.url
	# 				feed_entries = parsed_feed.entries
	# 				last_modified_time = parsed_feed.last_modified ? parsed_feed.last_modified.to_time.utc : nil
	# 				puts "Feed #{feed.name} from #{feed.source.name} has etag #{parsed_feed.etag} and  was last modified on #{last_modified_time} || #{feed.last_modified}"
	# 				if feed.last_modified != last_modified_time || last_modified_time == nil
	# 					feed.update(last_modified: last_modified_time)
	# 					feed_entries.each do |entry|
	# 						if entry.published
	# 							next if entry.published.to_date < Date.today - 3.days || entry.published.to_date > Date.tomorrow
	# 						end
	# 						resolved_url = resolve_url(entry.url)
	# 						Article.where(url: resolved_url).first_or_create do |article|
	# 							article.title = entry.title
	# 							article.url = resolved_url
	# 							article.pub_date = entry.published
	# 							article.summary = entry.summary
	# 							article.feed_id = feed.id

	# 							if entry.categories.length > 0
	# 								entry.categories.each do |category|
	# 									cat = Cat.where(name: category.downcase.strip).first_or_create
	# 									cat.articles << article
	# 								end
	# 							end

	# 						end
	# 					end
	# 				else
	# 					puts "Feed #{feed.name} from #{feed.source.name} has no new entries"
	# 				end
	# 			end				
	# 		end
	# 	end

end

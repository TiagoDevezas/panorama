	require 'open-uri'
class Article < ActiveRecord::Base
	after_save :get_social_shares
  belongs_to :feed
  has_and_belongs_to_many :cats

  validates :title, :url, presence: true, uniqueness: true

  default_scope { order('pub_date DESC') }

  # scope :published_between_with_date, -> (start_day) {
  # 	where("pub_date BETWEEN ? AND ?", 
		# 			start_day.to_datetime, start_day.to_datetime + 1)
  # }

  # scope :published_between_without_date, -> (start_day) {
  # 	where(pub_date: nil).where("articles.created_at BETWEEN ? AND ?", 
		# 			start_day.to_datetime, start_day.to_datetime + 1)
  # }

  def self.find_articles_with(query)
  	self.where("lower(title) LIKE ? OR lower(summary) LIKE ?", "%#{query.downcase}%", "%#{query.downcase}%")
  end

  def self.with_category(category)
  	Cat.find_by_name!(category).articles
  end

  def self.category_list
  	# not right yet
  	category_list = []
  	articles_with_category = self.includes(:cats)
  	articles_with_category.each do |article|
  		article.cats.each { |cat| category_list << [ cat.name, cat.articles.count ] }
  	end
  	category_list = category_list.uniq.compact.sort_by { |e| e[1] }.reverse
  	# category_list = []
  	# self.all.each do |article|
  	# 	article.cats.each { |cat| category_list << cat }
  	# end
  	# category_list = category_list.uniq.compact
  end

  def category_list
  	cats.map(&:name).join(', ')
  end

  def self.get_unique_days
  	days = []
  	self.all.each do |article|
  		if article.pub_date != nil
  			days << article.pub_date.strftime('%Y-%m-%d')
  		else
  			days << article.created_at.strftime('%Y-%m-%d')
  		end
  	end
		# days = self.pluck(:pub_date).map do |date|
		# 	if date
		# 		date.strftime('%Y-%m-%d')
		# 	end
		# end
		days = days.compact.uniq.sort
	end

	# def self.get_categories
	# 	categories = []
	# 	self.all.each do |article|
	# 		article.categories.each do |category|
	# 			categories << category
	# 		end
	# 	end
	# 	categories
	# end

	def self.get_count_by(time_period)
		time_and_totals = []
		if time_period == 'day'
			days = self.get_unique_days
			days.each do |day|
				articles = self.where("pub_date BETWEEN ? AND ?", 
					day.to_datetime, day.to_datetime + 1)
				# Workaround for P3 articles without publishing date. We use the updated_at date instead of the inexisting pub_date
				#articles_no_pub_date = self.where(pub_date: nil).where("articles.created_at BETWEEN ? AND ?", 
					#day.to_datetime, day.to_datetime + 1)
				#articles += articles_no_pub_date
				count = articles.count
				twitter_shares = articles.map(&:twitter_shares).sum
				facebook_shares = articles.map(&:facebook_shares).sum
				total_shares = twitter_shares + facebook_shares
				time_and_totals << Hash[ 
					time: day, 
					count: count, 
					twitter_shares: twitter_shares, 
					facebook_shares: facebook_shares, 
					total_shares: total_shares 
				]
			end
		end
		if time_period == 'month'
			(1..12).to_a.each do |month|
				articles = self.where("extract(month from pub_date) = ?", month)
				# Workaround for P3 articles without publishing date. We use the updated_at date instead of the inexisting pub_date
				#articles_no_pub_date = self.where(pub_date: nil).where("extract(month from created_at) = ?", month)
				#articles += articles_no_pub_date
				count = articles.count
				twitter_shares = articles.map(&:twitter_shares).sum
				facebook_shares = articles.map(&:facebook_shares).sum
				total_shares = twitter_shares + facebook_shares
				time_and_totals << Hash[ 
					time: month, 
					count: count, 
					twitter_shares: twitter_shares, 
					facebook_shares: facebook_shares, 
					total_shares: total_shares 
				]
			end
		end
		if time_period == 'hour'
			(0..23).to_a.each do |hour|
				articles = self.where("extract(hour from pub_date) = ?", hour)
				# Workaround for P3 articles without publishing date. We use the updated_at date instead of the inexisting pub_date
				#articles_no_pub_date = self.where(pub_date: nil).where("extract(hour from created_at) = ?", hour)
				#articles += articles_no_pub_date
				count = articles.count
				twitter_shares = articles.map(&:twitter_shares).sum
				facebook_shares = articles.map(&:facebook_shares).sum
				total_shares = twitter_shares + facebook_shares
				time_and_totals << Hash[ 
					time: hour, 
					count: count, 
					twitter_shares: twitter_shares, 
					facebook_shares: facebook_shares, 
					total_shares: total_shares 
				]
			end
		end
		time_and_totals
	end

	def get_social_shares
  	twitter_url = "https://cdn.api.twitter.com/1/urls/count.json?url="
  	facebook_url = "https://api.facebook.com/method/links.getStats?format=json&urls="
  	article_url = ERB::Util.url_encode(self.url)
  	twitter_response = open(twitter_url + article_url).read
  	twitter_shares = JSON.parse(twitter_response)['count']
  	facebook_response = open(facebook_url + article_url).read
  	facebook_shares = JSON.parse(facebook_response)[0]['share_count']
  	shares = Hash['twitter' => twitter_shares, 'facebook' => facebook_shares]
  	#self.update(twitter_shares: shares['twitter'], facebook_shares: shares['facebook'])
  	if self.twitter_shares != shares['twitter']
  		self.update(twitter_shares: shares['twitter'])
  		puts "Twitter shares changed"
  	end
  	if self.facebook_shares != shares['facebook']
  		self.update(facebook_shares: shares['facebook'])
  		puts "Facebook shares changed"
		end
	end

end

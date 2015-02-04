class Article < ActiveRecord::Base
	# after_commit :get_social_shares
  belongs_to :feed
  has_and_belongs_to_many :cats

  validates :url, uniqueness: true, presence: true 
  validates :title, presence: true

  default_scope { order('pub_date DESC') }

  # scope :published_between_with_date, -> (start_day) {
  # 	where("pub_date BETWEEN ? AND ?", 
		# 			start_day.to_datetime, start_day.to_datetime + 1)
  # }

  # scope :published_between_without_date, -> (start_day) {
  # 	where(pub_date: nil).where("articles.created_at BETWEEN ? AND ?", 
		# 			start_day.to_datetime, start_day.to_datetime + 1)
  # }

  def self.find_duplicates
  	dups_ids = []
  	grouped_by_title = all.order('created_at DESC').group_by { |article| [article.url] }
  	grouped_by_title.values.each do |group|
			first_record = group.shift
			group.each { |double| dups_ids << double.id }
  	end
  	dups_ids
  end

  def self.find_in_title(query)
  	self.where("lower(title) LIKE ?", "%#{query.downcase}%")
  end

  def self.find_in_summary(query)
  	self.where("lower(summary) LIKE ?", "%#{query.downcase}%")
  end

  def self.find_articles_with(query)
  	self.where("lower(title) LIKE ? OR lower(summary) LIKE ?", "%#{query.downcase}%", "%#{query.downcase}%")
  end

  def self.with_source_type(type)
  	self.joins(:feed => :source).where('source_type LIKE ?', type)
	end

  def self.with_category(category)
  	articles = self.joins(:cats).where('cats.name LIKE ?', category)
  end

  def self.category_list
  	category_list = []
  	articles_with_category = self.all.includes(:cats)
  	categories = articles_with_category.map { |a| a.cats }.flatten.uniq.compact
  	categories.map { |c| category_list << [c.name, c.articles.size]}
  	category_list = category_list.sort_by { |e| e[1] }.reverse
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
		days = days.compact.uniq.sort
	end

	def self.average_articles_by(time_period)
		articles = self.all
		article_count = articles.size
		if articles.where(pub_date: nil).count > 0
			articles = articles.reorder('created_at DESC')
			first_date = articles.first.created_at
			last_date = articles.last.created_at
		else
			first_date = articles.first.pub_date
			last_date = articles.last.pub_date
		end
		if time_period == 'day'
			num_days = (first_date.to_date - last_date.to_date).to_i
			avg_per_day = num_days > 0 ? (article_count / num_days).to_f.round(2) : article_count
		elsif time_period == 'month'
			num_months = 12 * (first_date.year - last_date.year) + first_date.month - last_date.month
			avg_per_month = num_months > 0 ? article_count / num_months : 0
		end		
	end

	def self.get_count_by(time_period)
		time_and_totals = []
		if time_period == 'day'
			# articles = self.all.unscoped
			# days_and_counts = articles.group_by_day(:pub_date, format: '%Y-%m-%d').count
			# days_and_counts.each do |day, count|
			# 	day = day.strftime('%Y-%m-%d')
			# 	count = count
			# 	articles_for_day = articles.where("pub_date BETWEEN ? AND ?", day.to_datetime, day.to_datetime + 1)
			# 	twitter_shares = articles_for_day.map(&:twitter_shares).compact.sum
			# 	facebook_shares = articles_for_day.map(&:facebook_shares).compact.sum
			# 	total_shares = twitter_shares + facebook_shares
			# 	time_and_totals << Hash[
			# 		time: day,
			# 		count: count,
			# 		twitter_shares: twitter_shares,
			# 		facebook_shares: facebook_shares,
			# 		total_shares: total_shares
			# 	]				
			# end
			#
			#articles = self.all
			#article_array = self.all.to_a
			#article_array = []
			#self.find_each(batch_size: 5000) { |a| article_array << a }
			#days  = article_array.group_by_day{|u| u.pub_date != nil ? u.pub_date : u.created_at }.map{|k, v| [k.strftime('%Y-%m-%d'), v.length, v.map(&:twitter_shares).compact.sum, v.map(&:facebook_shares).compact.sum] }
			
			days_and_counts = self.reorder('').group("to_char(pub_date, 'YYYY-MM-DD')")
																			 .select("to_char(pub_date, 'YYYY-MM-DD') as pubdate, COUNT(*) as article_count, SUM(twitter_shares) as twitter_shares, SUM(facebook_shares) as facebook_shares")
																			 .order("to_char(pub_date, 'YYYY-MM-DD')")
																			 .collect { |a| [a.pubdate, a.article_count, a.twitter_shares, a.facebook_shares] }

			#days_and_counts = self.reorder('').group_by_day(:pub_date, format: "%Y-%m-%d").count
			#days = self.get_unique_days
			days_and_counts.each do |day, count, twitter_shares, facebook_shares|
				#articles_for_day = self.where("to_char(pub_date, 'YYYY-MM-DD') = ?", day)
				#articles_for_day = articles.where("pub_date BETWEEN ? AND ?", 
					#day.to_datetime, day.to_datetime + 1)
				# Workaround for P3 articles without publishing date. We use the updated_at date instead of the inexisting pub_date
				#articles_no_pub_date = self.where(pub_date: nil).where("articles.created_at BETWEEN ? AND ?", 
					#day.to_datetime, day.to_datetime + 1)
				#articles += articles_no_pub_date
				#article_count = articles_for_day.length
				article_count = count
				#twitter_shares = 0
				#facebook_shares = 0
				#social_shares = self.where("to_char(pub_date, 'YYYY-MM-DD') = ?", day).pluck(:twitter_shares, :facebook_shares)
				#social_shares_array = social_shares.transpose.map { |a| a.compact.sum }
				twitter_shares = twitter_shares || 0
				facebook_shares = facebook_shares || 0
				#twitter_shares = self.where("to_char(pub_date, 'YYYY-MM-DD') = ?", day).pluck(:twitter_shares).compact.sum
				#facebook_shares = self.where("to_char(pub_date, 'YYYY-MM-DD') = ?", day).pluck(:facebook_shares).compact.sum
				total_shares = twitter_shares + facebook_shares
				time_and_totals << Hash[ 
					time: day, 
					count: article_count, 
					twitter_shares: twitter_shares, 
					facebook_shares: facebook_shares, 
					total_shares: total_shares 
				]
			end
		end
		if time_period == 'month'
			(1..12).to_a.each do |month|
				months_and_counts = self.reorder('').where("extract(month from pub_date) = ?", month)
											 .select("COUNT(*) as article_count, SUM(twitter_shares) as twitter_shares, SUM(facebook_shares) as facebook_shares")
											 .collect { |a| [a.article_count, a.twitter_shares, a.facebook_shares] }[0]
				# Workaround for P3 articles without publishing date. We use the updated_at date instead of the inexisting pub_date
				#articles_no_pub_date = self.where(pub_date: nil).where("extract(month from created_at) = ?", month)
				#articles += articles_no_pub_date
				count = months_and_counts[0]
				twitter_shares = months_and_counts[1] || 0
				facebook_shares = months_and_counts[2] || 0
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
				hours_and_counts = self.reorder('').where("extract(hour from pub_date) = ?", hour)
											 .select("COUNT(*) as article_count, SUM(twitter_shares) as twitter_shares, SUM(facebook_shares) as facebook_shares")
											 .collect { |a| [a.article_count, a.twitter_shares, a.facebook_shares] }[0]
				# Workaround for P3 articles without publishing date. We use the updated_at date instead of the inexisting pub_date
				#articles_no_pub_date = self.where(pub_date: nil).where("extract(hour from created_at) = ?", hour)
				#articles += articles_no_pub_date
				count = hours_and_counts[0]
				twitter_shares = hours_and_counts[1] || 0
				facebook_shares = hours_and_counts[2] || 0
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
		if time_period == 'week'
			(1..7).to_a.each do |weekday|
				weekdays_and_counts = self.reorder('').where("extract(ISODOW from pub_date) = ?", weekday)
											 .select("COUNT(*) as article_count, SUM(twitter_shares) as twitter_shares, SUM(facebook_shares) as facebook_shares")
											 .collect { |a| [a.article_count, a.twitter_shares, a.facebook_shares] }[0]
				count = weekdays_and_counts[0]
				twitter_shares = weekdays_and_counts[1] || 0
				facebook_shares = weekdays_and_counts[2] || 0
				total_shares = twitter_shares + facebook_shares
				time_and_totals << Hash[ 
					time: weekday, 
					count: count, 
					twitter_shares: twitter_shares, 
					facebook_shares: facebook_shares,
					total_shares: total_shares 
				]
			end
		end
		time_and_totals
	end

end

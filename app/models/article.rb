class Article < ActiveRecord::Base
  # after_commit :get_social_shares
  belongs_to :feed, counter_cache: true
  has_and_belongs_to_many :cats

  validates :url, uniqueness: true, presence: true
  validates_format_of :url, with: URI::regexp(%w(http https))
  validates :title, presence: true

  default_scope { order('pub_date DESC') }

  def self.strip_html_from_summary
    s = FeedCrawler.new
    find_each do |article|
      clean_summary = s.strip_html(article.summary)
      article.update_attribute(:summary, clean_summary) if article.summary != clean_summary
    end
  end

  def self.find_duplicates
    dups_ids = []
    duplicate_groups = self.reorder('').group(:url).having("count(*) > 1").select(:url, "array_agg(id) as id_array").collect { |a| a.id_array }
    duplicate_groups.each do |group|
      id_to_keep = group.shift
      group.each { |dup| dups_ids << dup}
    end
    dups_ids

   #  grouped_by_title = all.order('created_at DESC').group_by { |article| [article.url] }
    # grouped_by_title.values.each do |group|
      # first_record = group.shift
      # group.each { |double| dups_ids << double.id }
    # end
    # dups_ids
  end

  def self.clean_urls
    articles_with_dirty_urls = self.where('url LIKE ?', '%utm_%')
    articles_with_dirty_urls.each do |article|
      new_url = Addressable::URI.parse(article.url)
      query_params = new_url.query_values
      if query_params
        clean_query_params = query_params.reject { |k, v| k.start_with?('utm_')}
        new_url.query_values = clean_query_params
        if new_url.to_s != article.url
          article.update_attribute(:url, new_url.to_s)
        end
      end
    end
  end

  def self.find_in_title(query)
    where("tsv_title @@ #{sanitize_query(query)}") || nil
    # self.where("tsv_title @@ to_tsquery('simple', :q)", q: sanitize(query))
    #self.where("lower(title) LIKE ?", "%#{query.downcase}%")
  end

  def self.find_in_title_exact(query)
    where("tsv_title @@ #{sanitize_query(query)} AND title ILIKE :q", q: "%#{query}%") || nil
  end

  def self.find_in_summary(query)
    where("tsv_summary @@ #{sanitize_query(query)}") || nil
    # self.where("tsv_summary @@ to_tsquery('simple', :q)", q: sanitize(query))
    #self.where("lower(summary) LIKE ?", "%#{query.downcase}%")
  end

  def self.find_in_summary_exact(query)
    where("tsv_summary @@ #{sanitize_query(query)} AND summary ILIKE :q", q: "%#{query}%") || nil
  end

  def self.find_articles_with(query)
    logger.info(query)
    logger.info(query.chars[0] == '"')
    if query.chars[0] == '"' && query.chars[query.chars.length-1] == '"'
      new_query = query.gsub(/"+/,'')
      Article.find_articles_with_exact(new_query)
    else
      where("tsv_title @@ #{sanitize_query(query)} OR tsv_summary @@ #{sanitize_query(query)}") || nil
    end
    # split_query = query.split(" ")
    # if !query[/[&||!]/] && split_query.length > 1
    #   query = "#{sanitize(query)}"
    # end
    # self.where("tsv_title @@ to_tsquery('simple', :q) OR tsv_summary @@ to_tsquery('simple', :q)", q: query)
    # self.where("to_tsvector('simple', title) @@ to_tsquery('simple', :q) OR to_tsvector('simple', summary) @@ to_tsquery('simple', :q)", q: query)
  end

  def self.find_articles_with_exact(query)
    new_query = query.split(' ').join(' & ')
    where("(tsv_title @@ #{sanitize_query(query)} AND title ILIKE :q) OR (tsv_summary @@ #{sanitize_query(query)} AND summary ILIKE :q)", q: "%#{query}%") || nil
  end

  def self.sanitize_query(query, conjunction=' && ')
    "(" + tokenize_query(query).map {|t| term(t)}.join(conjunction) + ")"
  end

  def self.tokenize_query(query)
    query.split(/(\s|[&|:])+/)
  end

  def self.term(t)
    t = t.gsub(/^'+/,'')
    t = t.gsub(/[()]/, '')

    "to_tsquery('simple', #{quote_value t, nil})"
  end

  def self.search(query)
    where("tsv_title @@ #{sanitize_query(query)} OR tsv_summary @@ #{sanitize_query(query)}")
  end

  def self.search_title_and_summary(query)
    self.where("to_tsvector('simple', title) @@ to_tsquery(:q) OR to_tsvector('simple', summary) @@ to_tsquery(:q)", q: sanitize(query))
  end

  def self.with_source_type(type)
    self.joins(:feed => :source).where('source_type LIKE ?', type)
  end

  def self.with_source(source_name)
    self.joins(:feed => :source).where('sources.name LIKE ?', source_name)
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

  def self.title_words
    words = pluck('strip(tsv_title)').map {|a| !a.empty? ? a[1..-2].split('\' \'') : nil }.flatten.compact
    count_words(words)
  end

  def self.summary_words
    words = pluck('strip(tsv_summary)').map {|a| !a.empty? ? a[1..-2].split('\' \'') : nil }.flatten.compact
    count_words(words)
  end

  def self.title_and_summary_words
    words = pluck('strip(tsv_title)', 'strip(tsv_summary)').flatten.map {|a| !a.empty? ? a[1..-2].split('\' \'') : nil }.flatten.compact
    count_words(words)
  end

  def self.count_words(words)
    words.each_with_object(Hash.new(0)) { |word,counts| counts[word] += 1 }
          .sort {|a,b| b[1]<=>a[1]}.to_h
  end

  def count_words(words)
    words.each_with_object(Hash.new(0)) { |word,counts| counts[word] += 1 }
          .sort {|a,b| b[1]<=>a[1]}.to_h
  end

  def title_words
    words = Article.where(id: self.id).pluck('strip(tsv_title)')
    if !words.empty?
      words[0][1..-2].split('\' \'')
    else
      nil
    end
  end

  def summary_words
    words = Article.where(id: self.id).pluck('strip(tsv_summary)')
    if !words.empty?
      words[0][1..-2].split('\' \'')
    else
      nil
    end
  end

  def title_and_summary_words
    words = Article.where(id: self.id).pluck('strip(tsv_summary)').flatten
    if !words.empty?
      words[0][1..-2].split('\' \'')
    else
      nil
    end
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
    
    if time_period == 'day_only_count'
      days_and_counts = reorder('').group("to_char(pub_date, 'YYYY-MM-DD')")
                           .select("to_char(pub_date, 'YYYY-MM-DD') as pubdate, COUNT(*) as article_count")
                           .order("to_char(pub_date, 'YYYY-MM-DD')")
                           .collect { |a| [a.pubdate, a.article_count] }
      days_and_counts.each do |day, count|
        article_count = count
        time_and_totals << Hash[
          time: day,
          count: article_count
        ]
      end
    end
    if time_period == 'day'  
      days_and_counts = self.reorder('').group("to_char(pub_date, 'YYYY-MM-DD')")
                             .select("COUNT(*) as article_count, to_char(pub_date, 'YYYY-MM-DD') as pubdate, SUM(twitter_shares) as twitter_shares, SUM(facebook_shares) as facebook_shares")
                             .order("to_char(pub_date, 'YYYY-MM-DD')")
                             .collect { |a| [a.pubdate, a.article_count, a.twitter_shares, a.facebook_shares] }
                             
      #date_hash = Hash[*days_and_counts.map { |i| [Date.strptime(i[0], '%Y-%m-%d'), i[1]]}.flatten]
      date_array = days_and_counts.map { |i| [Date.strptime(i[0], '%Y-%m-%d'), i[1], i[2], i[3]]}

      return time_and_totals if !date_array[0]

      first_date = date_array[0].first
      last_date = date_array[-1].first

      flat_array = date_array.flatten

      first_date.upto(last_date) do |d, i|
        if !flat_array.include? d
          date_array << [d, 0, 0, 0]
        end
      end

      date_array.each { |el| el[0] = el[0].strftime('%Y-%m-%d')}

      date_array.sort_by! { |e| e[0] }

      date_array.each do |day, count, twitter_shares, facebook_shares|
        day = day
        article_count = count || 0
        twitter_shares = twitter_shares || 0
        facebook_shares = facebook_shares || 0
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
      months_and_counts = reorder('').group("extract(month from pub_date)")
                                     .select("extract(month from pub_date) as month, 
                                              COUNT(*) as article_count,
                                              SUM(twitter_shares) as twitter_shares,
                                              SUM(facebook_shares) as facebook_shares")
                                     .collect { |a| [a.month.to_i, a.article_count, a.twitter_shares, a.facebook_shares]}

      # (1..12).to_a.each do |month|
      #   months_and_counts = self.reorder('').where("extract(month from pub_date) = ?", month)
      #                  .select("COUNT(*) as article_count, SUM(twitter_shares) as twitter_shares, SUM(facebook_shares) as facebook_shares")
      #                  .collect { |a| [a.article_count, a.twitter_shares, a.facebook_shares] }[0]
        # Workaround for P3 articles without publishing date. We use the updated_at date instead of the inexisting pub_date
        #articles_no_pub_date = self.where(pub_date: nil).where("extract(month from created_at) = ?", month)
        #articles += articles_no_pub_date
      months_and_counts.each do |month, count, twitter_shares, facebook_shares|
        month = month
        count = count
        twitter_shares = twitter_shares || 0
        facebook_shares = facebook_shares || 0
        total_shares = twitter_shares + facebook_shares
        time_and_totals << Hash[ 
          time: month, 
          count: count, 
          twitter_shares: twitter_shares, 
          facebook_shares: facebook_shares, 
          total_shares: total_shares 
        ]
      end
      # end
      time_and_totals = fill_blanks(time_and_totals, (1..12))
    end
    if time_period == 'hour'
      hours_and_counts = reorder('').group("extract(hour from pub_date)")
                                     .select("extract(hour from pub_date) as hour, 
                                              COUNT(*) as article_count,
                                              SUM(twitter_shares) as twitter_shares,
                                              SUM(facebook_shares) as facebook_shares")
                                     .collect { |a| [a.hour.to_i, a.article_count, a.twitter_shares, a.facebook_shares]}
      hours_and_counts.each do |hour, count, twitter_shares, facebook_shares|
        hour = hour
        count = count
        twitter_shares = twitter_shares || 0
        facebook_shares = facebook_shares || 0
        total_shares = twitter_shares + facebook_shares
        time_and_totals << Hash[ 
          time: hour, 
          count: count, 
          twitter_shares: twitter_shares, 
          facebook_shares: facebook_shares, 
          total_shares: total_shares 
        ]
      end
      time_and_totals = fill_blanks(time_and_totals, (0..23))
      # (0..23).to_a.each do |hour|
      #   hours_and_counts = self.reorder('').where("extract(hour from pub_date) = ?", hour)
      #                  .select("COUNT(*) as article_count, SUM(twitter_shares) as twitter_shares, SUM(facebook_shares) as facebook_shares")
      #                  .collect { |a| [a.article_count, a.twitter_shares, a.facebook_shares] }[0]
      #   # Workaround for P3 articles without publishing date. We use the updated_at date instead of the inexisting pub_date
      #   #articles_no_pub_date = self.where(pub_date: nil).where("extract(hour from created_at) = ?", hour)
      #   #articles += articles_no_pub_date
      #   count = hours_and_counts[0]
      #   twitter_shares = hours_and_counts[1] || 0
      #   facebook_shares = hours_and_counts[2] || 0
      #   total_shares = twitter_shares + facebook_shares
      #   time_and_totals << Hash[ 
      #     time: hour, 
      #     count: count, 
      #     twitter_shares: twitter_shares, 
      #     facebook_shares: facebook_shares, 
      #     total_shares: total_shares 
      #   ]
      # end
    end
    if time_period == 'week'
      weekdays_and_counts = reorder('').group("extract(ISODOW from pub_date)")
                                     .select("extract(ISODOW from pub_date) as weekday, 
                                              COUNT(*) as article_count,
                                              SUM(twitter_shares) as twitter_shares,
                                              SUM(facebook_shares) as facebook_shares")
                                     .collect { |a| [a.weekday.to_i, a.article_count, a.twitter_shares, a.facebook_shares]}
      weekdays_and_counts.each do |weekday, count, twitter_shares, facebook_shares|
        weekday = weekday
        count = count
        twitter_shares = twitter_shares || 0
        facebook_shares = facebook_shares || 0
        total_shares = twitter_shares + facebook_shares
        time_and_totals << Hash[ 
          time: weekday, 
          count: count, 
          twitter_shares: twitter_shares, 
          facebook_shares: facebook_shares, 
          total_shares: total_shares 
        ]
      end
      time_and_totals = fill_blanks(time_and_totals, (1..7))
      # (1..7).to_a.each do |weekday|
      #   weekdays_and_counts = self.reorder('').where("extract(ISODOW from pub_date) = ?", weekday)
      #                  .select("COUNT(*) as article_count, SUM(twitter_shares) as twitter_shares, SUM(facebook_shares) as facebook_shares")
      #                  .collect { |a| [a.article_count, a.twitter_shares, a.facebook_shares] }[0]
      #   count = weekdays_and_counts[0]
      #   twitter_shares = weekdays_and_counts[1] || 0
      #   facebook_shares = weekdays_and_counts[2] || 0
      #   total_shares = twitter_shares + facebook_shares
      #   time_and_totals << Hash[ 
      #     time: weekday, 
      #     count: count, 
      #     twitter_shares: twitter_shares, 
      #     facebook_shares: facebook_shares,
      #     total_shares: total_shares 
      #   ]
      # end
    end
    time_and_totals
  end

  private

  def self.fill_blanks(collection, range)
    collection = collection
    range = range.to_a
    collection_grouped_by_time = collection.group_by { |el| el[:time].to_i }

    if collection_grouped_by_time.length != range.length
      range.each do |el|
        el = el.to_i
        if(!collection_grouped_by_time[el])
          collection << Hash[
            time: el,
            count: 0,
            twitter_shares: 0,
            facebook_shares: 0,
            total_shares: 0
          ]
        end
      end
    end
    collection.sort_by {|a| a[:time] }
  end

end

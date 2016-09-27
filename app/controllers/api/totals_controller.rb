module Api
  class TotalsController < ApplicationController
    include CheckApiTimeConstraints
    include CacheConfig
    respond_to :json

    def index

      source = params[:source]
      feed_id = params[:feed_id]
      by = params[:by]
      query = params[:q]
      fields = params[:fields]
      category = params[:category]
      type = params[:type]
      start_date = params[:since]
      end_date = params[:until]
      
      @days_and_totals = []

      if query
        if !fields
          @articles = Article.reorder('').find_articles_with(query)
        elsif fields == 'title'
          @articles = Article.reorder('').find_in_title(query)
        elsif fields  == 'summary'
          @articles = Article.reorder('').find_in_summary(query)
        end
        if type
          @articles = @articles.with_source_type(type)
          # @query_article_count = @articles.size
          @all_type_articles = Article.with_source_type(type)
          @type_article_count = @all_type_articles.size
        end
        if source
          source = Source.where(name: source).empty? ? Source.where(acronym: source).first : Source.where(name: source).first
          @all_source_articles = source.articles
          @articles = @articles.joins(:feed => :source).where('sources.name LIKE ? OR sources.acronym LIKE ?', "#{source.name}", "#{source.acronym}")
          @query_article_count = @articles.size
          @source_article_count = source.articles.size
        end
      #there's no query
      else
        if source
          source = Source.where(name: source).empty? ? Source.where(acronym: source).first : Source.where(name: source).first
          @articles = source.articles
          if feed_id && !source.feeds.where(id: feed_id.to_i).empty?
            @articles = Feed.find(feed_id).articles
          end
          @source_article_count = @articles.size
        elsif type
          @articles = Article.with_source_type(type)
          @type_article_count = @articles.size
        else
          @articles = Article.all
        end
      end

      if category
        @articles = @articles.with_category(category)
      end
      @articles = check_time_constraints(@articles)
      @all_type_articles_for_period = check_time_constraints(@all_type_articles) if @all_type_articles
      @all_source_articles_for_period = check_time_constraints(@all_source_articles) if @all_source_articles
      #@time_period_count = @articles.size || nil
      if !by || by == 'day'
        @days_and_totals = @articles.get_count_by('day')
        if @all_type_articles
          @days_and_totals_for_type = Rails.cache.fetch("all_#{type.to_s}_articles", expires_in: 6.hours) do
            # @all_type_articles_for_period.get_count_by('day')
            @all_type_articles.get_count_by('day')
          end
        end
        if @all_source_articles
          @days_and_totals_for_source = Rails.cache.fetch("all_#{source.to_s}_articles", expires_in: 6.hours) do
            @all_source_articles.get_count_by('day')
            # @all_source_articles_for_period.get_count_by('day')
          end
        end
        # if @get_percent_of_source_type 
        #   first_date = @days_and_totals.first[:time]
        #   last_date = @days_and_totals.last[:time]
        #   @source_type_totals = Article.with_source_type(type).reorder('').where("to_char(pub_date, 'YYYY-MM-DD') BETWEEN ? AND ?", first_date, last_date).get_count_by('day_only_count')
        # end
      end
      if by == 'month'
        @days_and_totals = @articles.get_count_by('month')
      end
      if by == 'hour'
        @days_and_totals = @articles.get_count_by('hour')
      end
      if by == 'week'
        @days_and_totals = @articles.get_count_by('week')
      end

    end

    def word_count

      source = params[:source]
      query = params[:q]
      type = params[:type]
      start_date = params[:since]
      end_date = params[:until]

      if query
        @articles = Article.find_articles_with(query)
        if type
          @articles = @articles.with_source_type(type)
        end
        if source
          source = Source.where(name: source).empty? ? Source.where(acronym: source).first : Source.where(name: source).first
          @articles = @articles.joins(:feed => :source).where('sources.name LIKE ? OR sources.acronym LIKE ?', "#{source.name}", "#{source.acronym}")
        end
      else
        if source
          source = Source.where(name: source).empty? ? Source.where(acronym: source).first : Source.where(name: source).first
          @articles = source.articles
        elsif type
          @articles = Article.with_source_type(type)
        else
          @articles = Article.all
        end
      end

      @articles = check_time_constraints(@articles)
      @articles_title_and_summary_words = @articles.title_and_summary_words

    end

    # API endpoint for photofinish viz
    def photo_finish
      query = params[:q]
      start_date = params[:since]
      end_date = params[:until]

      if start_date
        @articles = Article.reorder('')
          .where('pub_date >= ?', start_date.to_datetime)
          .find_articles_with(query)
          .joins(feed: :source).group('sources.name')
          .select('sources.name as s_name, count(*) as count, MIN(articles.pub_date) as first_pub, MIN(articles.id) as min_id')
          .map { |a| [a.s_name, a.count, a.first_pub, a.min_id, Article.find_by_id(a.min_id).url, Article.find_by_id(a.min_id).title, Article.find_by_id(a.min_id).twitter_shares, Article.find_by_id(a.min_id).facebook_shares] }.sort_by { |el| el[2] }
      end
      if end_date
        @articles = Article.reorder('')
          .where('pub_date <= ?', end_date.to_datetime + 1.day)
          .find_articles_with(query)
          .joins(feed: :source).group('sources.name')
          .select('sources.name as s_name, count(*) as count, MIN(articles.pub_date) as first_pub, MIN(articles.id) as min_id')
          .map { |a| [a.s_name, a.count, a.first_pub, a.min_id, Article.find_by_id(a.min_id).url, Article.find_by_id(a.min_id).title, Article.find_by_id(a.min_id).twitter_shares, Article.find_by_id(a.min_id).facebook_shares] }.sort_by { |el| el[2] }
      end
      if start_date && end_date
        @articles = Article.reorder('')
          .where('pub_date BETWEEN ? AND ?', start_date.to_datetime, end_date.to_datetime + 1.day)
          .find_articles_with(query)
          .joins(feed: :source).group('sources.name')
          .select('sources.name as s_name, count(*) as count, MIN(articles.pub_date) as first_pub, MIN(articles.id) as min_id')
          .map { |a| [a.s_name, a.count, a.first_pub, a.min_id, Article.find_by_id(a.min_id).url, Article.find_by_id(a.min_id).title, Article.find_by_id(a.min_id).twitter_shares, Article.find_by_id(a.min_id).facebook_shares] }.sort_by { |el| el[2] }
      end
      if !start_date && !end_date
        @articles = Article.reorder('')
          .find_articles_with(query)
          .joins(feed: :source)
          .group('sources.name')
          .select('sources.name as s_name, count(*) as count, MIN(articles.pub_date) as first_pub, MIN(articles.id) as min_id')
          .map { |a| [a.s_name, a.count, a.first_pub, a.min_id, Article.find_by_id(a.min_id).url, Article.find_by_id(a.min_id).title, Article.find_by_id(a.min_id).twitter_shares, Article.find_by_id(a.min_id).facebook_shares] }.sort_by { |el| el[2] }
      end
    end

  end

end
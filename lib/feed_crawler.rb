# require 'feedjira'
# require 'addressable/uri'
# require 'httpclient'
class FeedCrawler

	# Ugly hack to save feeds incorrectly identified as iTunes RSS
	classes_without_itunes = Feedjira::Feed.feed_classes.reject { |klass| klass == Feedjira::Parser::ITunesRSS }
	Feedjira::Feed.instance_variable_set(:'@feed_classes', classes_without_itunes)

	def crawl
		last_updated_feed = Feed.order('last_crawled ASC NULLS FIRST').first
		fetch_and_parse(last_updated_feed)
	end

	def crawl_source(source_name)
		source = Source.where(name: source_name).first
		source.feeds.each { |feed| fetch_and_parse(feed) }
	end

	def fetch_and_parse(feed)
		Rails.logger.debug "A actualizar feed #{feed.name} da fonte #{feed.source.name}, recolhida pela última vez em #{feed.last_crawled}"
		feed.update(last_crawled: DateTime.now)
		parsed_feed = Feedjira::Feed.fetch_and_parse feed.url
		if !parsed_feed.is_a? Integer
			feed_entries = parsed_feed.entries
			# safely do
			#feed.update(last_modified: last_modified_time)
				feed_entries.each do |entry|
					if entry.published
						next if entry.published.to_date <= Date.new(2014, 12, 05) || entry.published.to_date > Date.tomorrow
						#next if entry.published.to_date > Date.tomorrow
					end
					
					# Rails.logger.debug "Artigo com o url #{resolved_url} da fonte #{feed.source.name} já existe" if Article.where(url: resolved_url).exists?
					if Article.exists?(entry_id: entry.url)
						Rails.logger.debug "Artigo com o entry_id #{entry.entry_id} da fonte #{feed.source.name} já existe"
						next
					end
					resolved_url = resolve_url(entry.url)
					if Article.exists?(url: resolved_url)
						Rails.logger.debug "Artigo com o url #{resolved_url} da fonte #{feed.source.name} já existe"
						next
					end
					Article.create do |article|
						article.title = entry.title.strip
						article.url = resolved_url.strip
						article.pub_date = entry.published != nil ? entry.published : DateTime.now
						article.summary = strip_html(entry.summary) || strip_html(entry.content) || ''
						article.feed_id = feed.id
						article.entry_id = entry.url || nil

						if entry.categories.length > 0
							entry.categories.each do |category|
								cat = Cat.where(name: category.downcase.strip).first_or_create
								cat.articles << article
							end
						end
					end
				end
			# end
		end
	end

	# def safely
	# 	ActiveRecord::Base.connection_pool.with_connection do |conn|
	# 		ActiveRecord::Base.connection_pool.reap
	#     yield
	#     ActiveRecord::Base.connection_pool.remove(conn)
	#   end
	# end

	def strip_html(content)
		if content
			sanitizer = HTML::FullSanitizer.new
			sanitized = sanitizer.sanitize(content)
			content = sanitized.squish
		else
			content
		end
	end

	def resolve_url(entry_url)
		entry_url = entry_url.strip
		url = Addressable::URI.parse(entry_url)
		http_client = HTTPClient.new
		# Remove Google tracking parameters
		query_params = url.query_values
		if query_params
			clean_query_params = query_params.reject { |k, v| k.start_with?('utm_')}
			url.query_values = clean_query_params
		end
		begin
			resp = http_client.get(url, follow_redirect: true)
			resolved_url = resp.header.request_uri.to_s
			if resolved_url
				resolved_url
			else
				entry_url
			end
		rescue => e
			puts "Can't resolve URL, Error #{e}"
			entry_url
		end
	end

end
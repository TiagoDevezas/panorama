require 'feedjira'
require 'addressable/uri'
require 'httpclient'
class FeedCrawler

	# Ugly hack to save feeds incorrectly identified as iTunes RSS
	classes_without_itunes = Feedjira::Feed.feed_classes.reject { |klass| klass == Feedjira::Parser::ITunesRSS }
	Feedjira::Feed.instance_variable_set(:'@feed_classes', classes_without_itunes)

	def crawl
		last_updated_feed = Feed.order('last_crawled ASC').first
		fetch_and_parse(last_updated_feed)
	end

	def fetch_and_parse(feed)
		Rails.logger.info "A actualizar feed #{feed.name} da fonte #{feed.source.name}, recolhida pela última vez em #{feed.last_crawled}"
		feed.update(last_crawled: DateTime.now)
		parsed_feed = Feedjira::Feed.fetch_and_parse feed.url
		feed_entries = parsed_feed.entries
		#feed.update(last_modified: last_modified_time)
		feed_entries.each do |entry|
			if entry.published
				next if entry.published.to_date < Date.new(2014, 10, 01) || entry.published.to_date > Date.tomorrow
				#next if entry.published.to_date > Date.tomorrow
			end
			resolved_url = resolve_url(entry.url)
			Article.where(url: resolved_url).first_or_create do |article|
				article.title = entry.title
				article.url = resolved_url
				article.pub_date = entry.published
				article.summary = entry.summary
				article.feed_id = feed.id

				if entry.categories.length > 0
					entry.categories.each do |category|
						cat = Cat.where(name: category.downcase.strip).first_or_create
						cat.articles << article
					end
				end
			end
		end		
	end

	def resolve_url(entry_url)
		url = Addressable::URI.parse(entry_url)
		http_client = HTTPClient.new
		max_redirects = 2
		begin
			resp = http_client.get(url)
			resolved_url = resp.header['Location']
			if resolved_url.length > 0
				while max_redirects != 0
					new_location = http_client.get(resolved_url[0]).header['Location']
					break if new_location.length == 0
					resolved_url = new_location
					max_redirects -= 1
				end
				resolved_url[0]
			else
				entry_url
			end
		rescue => e
			puts "Can't resolve URL, Error #{e}"
			entry_url
		end
	end

end
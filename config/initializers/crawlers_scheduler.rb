require 'rufus-scheduler'
require 'feed_crawler'
require 'share_crawler'
# require 'rake'

# Panorama::Application.load_tasks

share_scheduler = Rufus::Scheduler.new(:lockfile => ".share-scheduler.lock")
feed_scheduler = Rufus::Scheduler.new(:lockfile => ".feed-scheduler.lock")
share_crawler = ShareCrawler.new
feed_crawler = FeedCrawler.new

unless share_scheduler.down?

share_scheduler.every '35', :overlap => false do

		begin
			share_crawler.get_social_shares('all')
			# system "rake panorama:get_all_shares"
			# share_crawler.get_social_shares('all')
			# task = Rake::Task['panorama:get_all_shares']
			# task.reenable
			# task.invoke
	  	Rails.logger.debug "Social shares updated at: #{Time.now}"
	  rescue => e
	  	Rails.logger.error "[ERROR] Updating social shares - #{e.message}"
	  end
	end

end

unless feed_scheduler.down?

	feed_scheduler.every '15', :overlap => false do
		begin
			feed_crawler.crawl
			# system "rake panorama:update_feeds"
			# feed_crawler.crawl
			# task = Rake::Task['panorama:update_feeds']
			# task.reenable
			# task.invoke 
			Rails.logger.debug "Articles updated at: #{Time.now}"
		rescue => e
			Rails.logger.error "[ERROR] Updating articles: #{e.message}"
		end
	end

end
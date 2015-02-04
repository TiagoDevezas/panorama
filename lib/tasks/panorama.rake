require 'feed_crawler'
require 'share_crawler'
namespace :panorama do
	desc "Atualiza todas as feeds na BD"
	task update_feeds: :environment do
		#pid_file = '/tmp/update_feeds.pid'
		#raise 'pid file exists!' if File.exists? pid_file
		#File.open(pid_file, 'w') { |f| f.puts Process.pid }
		#begin
			crawler = FeedCrawler.new
			crawler.crawl
			#Source.update_feeds
		#ensure
			#File.delete pid_file
		#end
	end
	desc "Vai buscar o número de partilhas do artigo no Twitter"
	task get_twitter_shares: :environment do
		puts "A actualizar partilhas no Twitter..."
		share_crawler = ShareCrawler.new
		share_crawler.get_social_shares('twitter')
	end
	desc "Vai buscar o número de partilhas do artigo no Facebook"
	task get_facebook_shares: :environment do
		puts "A actualizar partilhas no Facebook..."
		share_crawler = ShareCrawler.new
		share_crawler.get_social_shares('facebook')
	end
	desc "Vai buscar o número de partilhas do artigo no Twitter e no Facebook"
	task get_all_shares: :environment do
		puts "A actualizar partilhas no Facebook..."
		share_crawler = ShareCrawler.new
		share_crawler.get_social_shares('all')
	end
end
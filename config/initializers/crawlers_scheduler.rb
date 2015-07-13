require 'rake'

Panorama::Application.load_tasks

share_scheduler = Rufus::Scheduler.new(:lockfile => ".share-scheduler.lock")
feed_scheduler = Rufus::Scheduler.new(:lockfile => ".feed-scheduler.lock")

def safely
	ActiveRecord::Base.connection_pool.with_connection do |conn|
    yield
  	ActiveRecord::Base.connection_pool.remove(conn)
  	conn.disconnect!
  end
end

unless share_scheduler.down?

	share_scheduler.every '15', :overlap => false do
		safely do
			begin
				share_crawler_task = Rake::Task['panorama:get_all_shares']
				share_crawler_task.reenable
				share_crawler_task.invoke
		  	Rails.logger.debug "Social shares updated at: #{Time.now}"
		  rescue => e
		  	Rails.logger.error "[ERROR] Updating social shares - #{e.message}"
		  end
		end
	end

end

unless feed_scheduler.down?

	feed_scheduler.every '10', :overlap => false do
		safely do
			begin
				feed_crawler_task = Rake::Task['panorama:update_feeds']
				feed_crawler_task.reenable
				feed_crawler_task.invoke 
				Rails.logger.debug "Articles updated at: #{Time.now}"
			rescue => e
				Rails.logger.error "[ERROR] Updating articles: #{e.message}"
			end
		end
	end

end
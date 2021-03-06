require 'rake'

Panorama::Application.load_tasks

feed_scheduler = Rufus::Scheduler.singleton
# share_scheduler = Rufus::Scheduler.singleton
solr_import_scheduler = Rufus::Scheduler.singleton

def safely
	ActiveRecord::Base.connection_pool.with_connection do |conn|
    yield
  	ActiveRecord::Base.connection_pool.remove(conn)
  	conn.disconnect!
  end
end

unless feed_scheduler.down?

	feed_scheduler.every '5', :overlap => false do
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

# unless share_scheduler.down?

# 	share_scheduler.every '16', :overlap => false do
# 		safely do
# 			begin
# 				share_crawler_task = Rake::Task['panorama:get_facebook_shares']
# 				share_crawler_task.reenable
# 				share_crawler_task.invoke
# 		  	Rails.logger.debug "Social shares updated at: #{Time.now}"
# 		  rescue => e
# 		  	Rails.logger.error "[ERROR] Updating social shares - #{e.message}"
# 		  end
# 		end
# 	end

# end

unless solr_import_scheduler.down?
  solr_import_scheduler.every '15m', :overlap => false do
    begin
      solr_import_task = Rake::Task['panorama:update_solr_index']
      solr_import_task.reenable
      solr_import_task.invoke
      Rails.logger.debug "Started updating Solr index at: #{Time.now}"
    rescue => e
      Rails.logger.error "[ERROR] Updating Solr index - #{e.message}"
    end
  end
end
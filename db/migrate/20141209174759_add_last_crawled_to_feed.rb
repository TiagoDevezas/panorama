class AddLastCrawledToFeed < ActiveRecord::Migration
  def change
    add_column :feeds, :last_crawled, :datetime
  end
end

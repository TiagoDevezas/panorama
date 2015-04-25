class AddArticlesCountToFeeds < ActiveRecord::Migration
  def change
    add_column :feeds, :articles_count, :integer, null: false, default: 0
    Feed.find_each do |f|
    	Feed.reset_counters(f.id, :articles)
    end
  end
end

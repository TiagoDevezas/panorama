class AddTwitterShareToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :twitter_shares, :integer, default: 0
  end
end

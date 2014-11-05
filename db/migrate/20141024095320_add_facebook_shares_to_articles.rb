class AddFacebookSharesToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :facebook_shares, :integer, default: 0
  end
end

class ChangeTwitterSharesDefaultValueToNilInArticles < ActiveRecord::Migration
  def change
  	change_column :articles, :twitter_shares, :integer, default: nil
  end
end

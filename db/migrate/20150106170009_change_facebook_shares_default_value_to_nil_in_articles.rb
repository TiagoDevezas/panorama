class ChangeFacebookSharesDefaultValueToNilInArticles < ActiveRecord::Migration
  def change
  	change_column :articles, :facebook_shares, :integer, default: nil
  end
end

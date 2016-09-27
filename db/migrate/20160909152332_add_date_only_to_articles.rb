class AddDateOnlyToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :date_only, :string
    add_index :articles, :date_only
  end
end

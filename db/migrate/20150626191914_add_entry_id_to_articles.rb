class AddEntryIdToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :entry_id, :string
  end
end

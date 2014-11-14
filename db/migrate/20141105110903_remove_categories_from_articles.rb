class RemoveCategoriesFromArticles < ActiveRecord::Migration
  def change
    remove_column :articles, :categories, :text
  end
end

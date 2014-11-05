class AddCategoriesToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :categories, :text, array: true, default: []
  end
end

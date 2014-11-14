class AddIndexToArticlesCats < ActiveRecord::Migration
  def change
  	add_index :articles_cats, [:article_id, :cat_id], unique: true, using: :btree
  end
end

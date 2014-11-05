class ArticlesCats < ActiveRecord::Migration
  def change
  	create_table :articles_cats, id: false do |t|
      t.belongs_to :article
      t.belongs_to :cat
    end
  end
end

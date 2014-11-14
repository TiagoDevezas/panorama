class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :title
      t.string :url
      t.datetime :pub_date
      t.references :feed, index: true

      t.timestamps
    end
  end
end

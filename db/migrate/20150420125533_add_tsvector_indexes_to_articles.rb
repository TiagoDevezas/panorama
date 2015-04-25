class AddTsvectorIndexesToArticles < ActiveRecord::Migration
  def change
  	execute "
    create index articles_title_idx on articles using gin(to_tsvector('simple', title));
    create index articles_summary_idx on articles using gin(to_tsvector('simple', summary));"
  end
end

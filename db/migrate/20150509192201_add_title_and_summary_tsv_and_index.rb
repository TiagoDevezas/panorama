class AddTitleAndSummaryTsvAndIndex < ActiveRecord::Migration
  def change
  	add_column :articles, :tsv_title, :tsvector
  	add_index(:articles, :tsv_title, using: 'gin')

  	add_column :articles, :tsv_summary, :tsvector
  	add_index(:articles, :tsv_summary, using: 'gin')

		create_trigger(compatibility: 1).on(:articles).before(:insert, :update) do
		  "
		  	new.tsv_summary := to_tsvector('pg_catalog.simple', coalesce(new.summary,''));
		  	new.tsv_title := to_tsvector('pg_catalog.simple', coalesce(new.title,''));
		  "
		end
  end
end

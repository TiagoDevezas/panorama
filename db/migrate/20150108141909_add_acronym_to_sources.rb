class AddAcronymToSources < ActiveRecord::Migration
  def change
    add_column :sources, :acronym, :string
  end
end

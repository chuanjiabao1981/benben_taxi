class ChangeColumName < ActiveRecord::Migration
  def change
  	rename_column :comments,:author,:author_id
  	rename_column :comments,:target,:target_id
  end
end

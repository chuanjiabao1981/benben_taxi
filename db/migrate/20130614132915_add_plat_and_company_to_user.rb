class AddPlatAndCompanyToUser < ActiveRecord::Migration
  def change
  	add_column :users,:plate,:string
  	add_column :users,:taxi_company_id,:integer
  	add_column :users,:register_info,:string
  end
end

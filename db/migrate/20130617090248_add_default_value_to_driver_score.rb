class AddDefaultValueToDriverScore < ActiveRecord::Migration
  def change
  	change_column :taxi_requests, :driver_score, :integer, :default => 5
  end
end

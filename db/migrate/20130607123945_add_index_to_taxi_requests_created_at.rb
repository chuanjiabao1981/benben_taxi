class AddIndexToTaxiRequestsCreatedAt < ActiveRecord::Migration
  def change
  	add_index :taxi_requests, :created_at
  end
end

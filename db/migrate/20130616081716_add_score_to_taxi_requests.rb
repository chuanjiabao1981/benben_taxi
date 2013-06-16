class AddScoreToTaxiRequests < ActiveRecord::Migration
  def change
  	  	add_column :taxi_requests,:passenger_score,:integer,:default => 5
  	  	add_column :taxi_requests,:driver_score,:integer,:defualt => 5
  end
end

class AddDriverIdIndexPassengerIdIndex < ActiveRecord::Migration
  def change
  	  	add_index :taxi_requests, :driver_id
  	  	add_index :taxi_requests, :passenger_id
  end
end

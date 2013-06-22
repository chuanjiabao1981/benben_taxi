class AddSuccessTaxiRequestToUser < ActiveRecord::Migration
  def change
  	add_column :users,:success_taxi_requests,:integer,:default => 0
  end
end

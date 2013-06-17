class AddScoreTimeToTaxiRequests < ActiveRecord::Migration
  def change
  	add_column :taxi_requests,:passenger_score_time,:timestamp
  	add_column :taxi_requests,:driver_score_time,:timestamp
  end
end

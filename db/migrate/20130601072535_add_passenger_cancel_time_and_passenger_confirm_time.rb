class AddPassengerCancelTimeAndPassengerConfirmTime < ActiveRecord::Migration
  def change
  	  	add_column :taxi_requests,:passenger_cancel_time,:timestamp
  	  	add_column :taxi_requests,:passenger_confirm_time,:timestamp
  end
end

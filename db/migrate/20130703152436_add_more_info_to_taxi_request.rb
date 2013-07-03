class AddMoreInfoToTaxiRequest < ActiveRecord::Migration
  def change
  	  	add_column :taxi_requests,:source,:string
  	  	add_column :taxi_requests,:destination,:string
  	  	add_column :taxi_requests,:plate,:string
  	  	add_column :taxi_requests,:driver_name,:string
  end
end

class CreateTaxiRequests < ActiveRecord::Migration
	def change
		create_table :taxi_requests do |t|
			t.string 			:state
			t.integer 			:lock_version
			t.references 		:passenger
			t.string 	 		:passenger_mobile
			t.point 	 		:passenger_location,:geographic => true,:srid=>4326		
			t.timestamp 		:timeout
			t.references 		:driver
			t.string 	 		:driver_mobile
			t.point 	 		:driver_location,:geographic => true,:srid=>4326
			t.timestamp 		:driver_response_time
			t.references 		:tenant
			t.timestamps
			t.index 			:passenger_location, :spatial => true
			t.index 			:state
			t.index 			:timeout
		end
	end
end

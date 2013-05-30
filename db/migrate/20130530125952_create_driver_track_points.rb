class CreateDriverTrackPoints < ActiveRecord::Migration
	def change
		create_table :driver_track_points do |t|
			t.references 		:driver
			t.string 			:mobile
			t.point 	 		:location,:geographic => true,:srid=>4326		
			t.float  			:radius
			t.string 			:coortype
			t.references 		:tenant
			t.timestamps
			t.index 			:location, :spatial => true
			t.index 			:tenant_id	
		end
		add_index :taxi_requests, :tenant_id

	end
end

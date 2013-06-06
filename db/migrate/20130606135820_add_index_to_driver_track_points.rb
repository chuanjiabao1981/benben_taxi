class AddIndexToDriverTrackPoints < ActiveRecord::Migration
  def change
  	add_index :driver_track_points, :driver_id
  	add_index :driver_track_points, :created_at
  end
end

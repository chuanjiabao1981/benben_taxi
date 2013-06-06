class AddIndexToDriverTrackPoints < ActiveRecord::Migration
  def change
  	add_index :driver_track_points, :driver_id
  end
end

class CreateAdvertisements < ActiveRecord::Migration
  def change
    create_table :advertisements do |t|
      t.text :content
      t.timestamp :start_time
      t.timestamp :end_time
      t.references :tenant
	  t.index 			:start_time
	  t.index			:end_time
      t.timestamps
    end
  end
end

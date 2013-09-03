class CreateRegisterVerifications < ActiveRecord::Migration
  def change
    create_table :register_verifications do |t|
      t.string    :mobile
      t.timestamp :delivered_time
      t.string    :status
      t.string    :code
      t.timestamps
    end
    add_index :register_verifications, [:mobile,:code] ,:name => 'verification_index'
  end
end

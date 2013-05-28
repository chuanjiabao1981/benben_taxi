class CreateTenants < ActiveRecord::Migration
  def change
    create_table :tenants do |t|
      t.string :name
      t.timestamps
    end
    add_index :tenants, :name
  end
end

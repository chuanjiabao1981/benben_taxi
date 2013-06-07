class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :mobile 
      t.string :account
      t.string :role
      t.references :tenant
      t.string :status 
      t.string :password_digest
      t.string :remember_token
      t.timestamps
    end
    add_index :users, :remember_token
    add_index :users, :mobile
    add_index :users, :account
    add_index :users, :tenant_id
  end
end

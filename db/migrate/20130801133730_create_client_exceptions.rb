class CreateClientExceptions < ActiveRecord::Migration
  def change
    create_table :client_exceptions do |t|
      t.string :client_version
      t.string :android_version
      t.string :ios_version
      t.string :role
      t.text :content
      t.timestamps
    end
  end
end
